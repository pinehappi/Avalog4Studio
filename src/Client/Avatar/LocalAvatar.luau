local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)
local Future = require(Avalog.Parent.Future)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local ScaleLimits = require(Avalog.SourceCode.Shared.ScaleLimits)
local SquashNumber = require(Avalog.SourceCode.Shared.Utils.SquashNumber)
local CatalogItems = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogItems)
local Zap = require(Avalog.SourceCode.Shared.Zap.client)
local EnumSerDes = require(Avalog.Parent.EnumSerDes)
local Sift = require(Avalog.Parent.Sift)
local Config = require(Avalog.Config)

export type CatalogItem = {
	Id: number,
	Type: Enum.AvatarItemType,
	AssetType: Enum.AvatarAssetType,
	Name: string,
}

local CONFIG = Config:Get()

local LocalAvatar = {
	Character = Instance.new("Model"),
	Humanoid = Instance.new("Humanoid"),
	HumanoidDescriber = HumanoidDescriber(Instance.new("HumanoidDescription")),
	Updated = Signal.new(),
}

function LocalAvatar:ApplyLimits()
	LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
		if #Data.Accessories > CONFIG.Limits.Accessories then
			Data.Accessories = Sift.Array.slice(Data.Accessories, 1, CONFIG.Limits.Accessories)
		end

		return Data
	end)
end

function LocalAvatar:UpdateServer(Data: HumanoidDescriber.Data): ()
	if Data then
		Zap.UpdateAvatar.Fire(EnumSerDes.SerializeTree(Data))
	end
end

function LocalAvatar:Redo()
	local UndoHistoryValue = Fusion.peek(States.Avatar.UndoHistory)
	local LastDataEntry = UndoHistoryValue[#UndoHistoryValue]

	if LastDataEntry then
		self.HumanoidDescriber:UpdateData(function()
			return LastDataEntry
		end)

		table.remove(UndoHistoryValue, #UndoHistoryValue)

		States.Avatar.UndoHistory:set(UndoHistoryValue)

		self:Apply()
	end
end

function LocalAvatar:Undo()
	local Data = self.HumanoidDescriber:GetData()
	local HistoryDataValue = Fusion.peek(States.Avatar.DataHistory)
	local LastDataEntry = HistoryDataValue[#HistoryDataValue - 1]

	if LastDataEntry then
		local UndoHistoryValue = Fusion.peek(States.Avatar.UndoHistory)

		self.HumanoidDescriber:UpdateData(function()
			return LastDataEntry
		end)

		table.remove(HistoryDataValue, #HistoryDataValue)
		table.insert(UndoHistoryValue, Data)

		States.Avatar.DataHistory:set(HistoryDataValue)
		States.Avatar.UndoHistory:set(UndoHistoryValue)

		self:Apply()
	end
end

function LocalAvatar:SaveAvatar()
	AvatarEditorService:PromptSaveAvatar(
		LocalAvatar.HumanoidDescriber.HumanoidDescription,
		LocalAvatar.Humanoid.RigType
	)
end

function LocalAvatar:UpdateScale(Property: string, Value: number)
	local Clamp = ScaleLimits[Property]
	if Clamp then
		Value = SquashNumber(Value, Clamp.Min, Clamp.Max)
	end

	self.HumanoidDescriber:UpdateData(function(Data)
		if Data.Scale[Property] ~= nil then
			Data.Scale[Property] = Value
		end

		return Data
	end)

	self:Apply()
end

function LocalAvatar:SetColor(Color: Color3)
	self.HumanoidDescriber:UpdateData(function(Data)
		for PartName, _ in pairs(Data.BodyPartColors) do
			Data.BodyPartColors[PartName] = Color
		end

		return Data
	end)

	self:Apply()
end

function LocalAvatar:PromptCheckout(Items)
	if #Items > 0 then
		Zap.BulkPurchaseAvatarItems.Fire(EnumSerDes.SerializeTree(Items))

		return true
	else
		return false
	end
end

function LocalAvatar:GetUnownedItems()
	local Items = {}

	local AssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
	local BundleIdsValue = Fusion.peek(States.Avatar.EquippedBundleIds)

	for _, AssetId in ipairs(AssetIdsValue) do
		local AssetInfo = CatalogItems:GetItem(AssetId, Enum.InfoType.Asset)

		if AssetInfo and not AssetInfo.Offsale then
			local Owned = CatalogItems:OwnsItem(AssetId, Enum.AvatarItemType.Asset)

			if Owned == false then
				table.insert(Items, {
					Id = tostring(AssetId),
					Type = Enum.MarketplaceProductType.AvatarAsset,
				})
			end
		end
	end

	for _, BundleId in ipairs(BundleIdsValue) do
		local ItemInfo = CatalogItems:GetItem(BundleId, Enum.InfoType.Bundle)

		if ItemInfo and not ItemInfo.Offsale then
			local Owned = CatalogItems:OwnsItem(BundleId, Enum.AvatarItemType.Bundle)

			if Owned == false then
				table.insert(Items, {
					Id = tostring(BundleId),
					Type = Enum.MarketplaceProductType.AvatarBundle,
				})
			end
		end
	end

	return Items
end

function LocalAvatar:ToggleCatalogItem(CatalogItem: CatalogItem)
	if CatalogItem.Type == Enum.AvatarItemType.Bundle then
		local BundleDetails = CatalogItems:GetBundle(CatalogItem.Id)
		local UserOutfit

		if BundleDetails then
			for _, BundleItem in ipairs(BundleDetails.Items) do
				if BundleItem.Type == "UserOutfit" then
					UserOutfit = BundleItem
					break
				end
			end

			if UserOutfit then
				local Success2, Result2 = Future.Try(function()
					return Players:GetHumanoidDescriptionFromOutfitId(UserOutfit.Id)
				end):Await()

				if Success2 then
					local BundleDescriber = HumanoidDescriber(Result2)
					local BundleData = BundleDescriber:GetData()

					if BundleDetails.BundleType == "BodyParts" then
						self.HumanoidDescriber:UpdateData(function(Data)
							Data.BodyParts = BundleData.BodyParts
							return Data
						end)
					elseif BundleDetails.BundleType == "AvatarAnimations" then
						self.HumanoidDescriber:UpdateData(function(Data)
							Data.Animations = BundleData.Animations
							return Data
						end)
					elseif BundleDetails.BundleType == "DynamicHead" then
						self.HumanoidDescriber:EquipAsset(BundleData.BodyParts.Head, Enum.AvatarAssetType.DynamicHead)
					end

					BundleDescriber:Destroy()
					Result2:Destroy()
				end
			end
		end
	elseif CatalogItem.Type == Enum.AvatarItemType.Asset then
		local Equipped = self.HumanoidDescriber:IsAssetEquipped(CatalogItem.Id, CatalogItem.AssetType)
		self.HumanoidDescriber:SetAssetEquipped(CatalogItem.Id, CatalogItem.AssetType, not Equipped)
	end

	LocalAvatar:ApplyLimits()

	self:Apply()
end

function LocalAvatar:Reset()
	local Success, Result = Future.Try(function()
		return Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId or 1)
	end):Await()

	if Success then
		LocalAvatar.HumanoidDescriber:ReadFromDescription(Result)
		self:Apply()
	end
end

function LocalAvatar:Apply()
	return Future.Try(function()
		LocalAvatar.Humanoid:ApplyDescriptionReset(LocalAvatar.HumanoidDescriber.HumanoidDescription)
	end):Await()
end

function LocalAvatar:SetCharacter(Character: Model)
	if not Players.LocalPlayer:HasAppearanceLoaded() then
		Players.LocalPlayer:GetPropertyChangedSignal("HasAppearanceLoaded"):Wait()
	end

	if Character then
		local OriginalCharacter = Character
		local OriginalHumanoid = OriginalCharacter:FindFirstChildOfClass("Humanoid")

		Character.Archivable = true
		Character = Character:Clone()
		Character:PivotTo(CFrame.new())

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid and OriginalHumanoid then
			local HumanoidDescription = Humanoid:FindFirstChildOfClass("HumanoidDescription")
			local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

			self.Character = Character
			self.Humanoid = Humanoid
			self.HumanoidDescriber = HumanoidDescriberObject

			OriginalCharacter.Humanoid.ApplyDescriptionFinished:Connect(function()
				HumanoidDescriberObject:ReadFromDescription(OriginalHumanoid:GetAppliedDescription())
				LocalAvatar:Apply()
			end)

			self.Updated:Fire()
		end
	end
end

if RunService:IsRunning() then
	Players.LocalPlayer.CharacterAdded:Connect(function(Character)
		LocalAvatar:SetCharacter(Character)
	end)

	local ExistingCharacter = Players.LocalPlayer.Character
	if ExistingCharacter then
		task.spawn(function()
			LocalAvatar:SetCharacter(ExistingCharacter)
		end)
	end
end

return LocalAvatar
