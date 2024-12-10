local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)
local Future = require(Avalog.Parent.Future)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.Extensions.CatalogSearch)

export type CatalogItem = {
	Id: number,
	Type: Enum.AvatarItemType,
	AssetType: Enum.AvatarAssetType,
	Name: string,
}

local LocalAvatar = {
	Character = Instance.new("Model"),
	Humanoid = Instance.new("Humanoid"),
	HumanoidDescriber = HumanoidDescriber(Instance.new("HumanoidDescription")),
	Updated = Signal.new(),
}

function LocalAvatar:SetColor(Color: Color3)
	self.HumanoidDescriber:UpdateData(function(Data)
		for PartName, _ in pairs(Data.BodyPartColors) do
			Data.BodyPartColors[PartName] = Color
		end

		return Data
	end)
end

function LocalAvatar:PromptCheckout()
	local Items = {}
	local AssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
	local BundleIdsValue = Fusion.peek(States.Avatar.EquippedBundleIds)

	States.Checkout.Loading:set(true)

	for _, AssetId in ipairs(AssetIdsValue) do
		local AssetInfo = CatalogSearch:GetProductInfo(AssetId, Enum.InfoType.Asset)

		if AssetInfo and not AssetInfo.Offsale then
			local Owned = CatalogSearch:OwnsItem(AssetId, Enum.AvatarItemType.Asset)

			if Owned == false then
				table.insert(Items, {
					Id = tostring(AssetId),
					Type = Enum.MarketplaceProductType.AvatarAsset,
				})
			end
		end
	end

	for _, BundleId in ipairs(BundleIdsValue) do
		local ItemInfo = CatalogSearch:GetProductInfo(BundleId, Enum.InfoType.Bundle)

		if ItemInfo and not ItemInfo.Offsale then
			local Owned = CatalogSearch:OwnsItem(BundleId, Enum.AvatarItemType.Bundle)

			if Owned == false then
				table.insert(Items, {
					Id = tostring(BundleId),
					Type = Enum.MarketplaceProductType.AvatarBundle,
				})
			end
		end
	end

	States.Checkout.Loading:set(false)

	if #Items > 0 then
		if next(States.Services.AvatarService) ~= nil then
			States.Services.AvatarService:BulkPurchaseItems(Items)
		end

		return true
	else
		return false
	end
end

function LocalAvatar:ToggleCatalogItem(CatalogItem: CatalogItem)
	if CatalogItem.Type == Enum.AvatarItemType.Bundle then
		local BundleDetails = CatalogSearch:GetBundleDetails(CatalogItem.Id)
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
		Character.Archivable = true
		Character = Character:Clone()
		Character:PivotTo(CFrame.new())

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			local HumanoidDescription = Humanoid:FindFirstChildOfClass("HumanoidDescription")
			local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

			self.Character = Character
			self.Humanoid = Humanoid
			self.HumanoidDescriber = HumanoidDescriberObject

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
		LocalAvatar:SetCharacter(ExistingCharacter)
	end
end

return LocalAvatar
