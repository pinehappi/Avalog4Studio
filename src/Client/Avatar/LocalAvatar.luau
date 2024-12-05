local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)
local Future = require(Avalog.Parent.Future)
local AssetAccessoryTypes = require(Avalog.SourceCode.Shared.AssetAccessoryType)
local AvatarAssetTypes = require(Avalog.SourceCode.Shared.AvatarAssetTypes)
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
	HumanoidDescriber = HumanoidDescriber.new(Instance.new("HumanoidDescription")),
	Updated = Signal.new(),
}

function LocalAvatar:PromptCheckout()
	local Items = {}
	local AssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)

	for _, AssetId in ipairs(AssetIdsValue) do
		local AssetInfo = CatalogSearch:GetAssetInfo(AssetId)

		if AssetInfo and not AssetInfo.Offsale then
			local Success, Result = Future.Try(function()
				return MarketplaceService:PlayerOwnsAsset(Players.LocalPlayer, AssetId)
			end):Await()

			if Success then
				if Result == false then
					table.insert(Items, {
						Id = tostring(AssetId),
						Type = Enum.MarketplaceProductType.AvatarAsset,
					})
				end
			end
		end
	end

	if next(States.Services.AvatarService) ~= nil then
		States.Services.AvatarService:BulkPurchaseItems(Items)
	end
end

function LocalAvatar:ToggleCatalogItem(CatalogItem: CatalogItem)
	if CatalogItem.Type == Enum.AvatarItemType.Bundle then
		local Success, Result = Future.Try(function()
			return AssetService:GetBundleDetailsAsync(CatalogItem.Id)
		end):Await()

		if Success then
			local UserOutfit

			for _, BundleItem in ipairs(Result.Items) do
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
					local BundleDescriber = HumanoidDescriber.new(Result2)
					local BundleData = BundleDescriber:GetData()

					if Result.BundleType == "BodyParts" then
						self.HumanoidDescriber:UpdateData(function(Data)
							Data.BodyParts = BundleData.BodyParts
							return Data
						end)
					elseif Result.BundleType == "AvatarAnimations" then
						self.HumanoidDescriber:UpdateData(function(Data)
							Data.Animations = BundleData.Animations
							return Data
						end)
					elseif Result.BundleType == "DynamicHead" then
						self.HumanoidDescriber:UpdateData(function(Data)
							Data.BodyParts.Head = BundleData.BodyParts.Head
							return Data
						end)
					end

					BundleDescriber:Destroy()
					Result2:Destroy()
				end
			end
		end
	elseif CatalogItem.Type == Enum.AvatarItemType.Asset then
		if table.find(AvatarAssetTypes.Types.Accessories, CatalogItem.AssetType) then
			local AccessoryType = AssetAccessoryTypes[CatalogItem.AssetType]
			if AccessoryType then
				LocalAvatar.HumanoidDescriber:ToggleAccessory({
					AssetId = CatalogItem.Id,
					AccessoryType = AccessoryType,
					Order = 1,
				})
			end
		elseif CatalogItem.AssetType == Enum.AvatarAssetType.Face then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				if Data.Face ~= CatalogItem.Id then
					Data.Face = CatalogItem.Id
				else
					Data.Face = 0
				end

				return Data
			end)
		elseif table.find(AvatarAssetTypes.Types.Clothing, CatalogItem.AssetType) then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				if Data.Clothing[CatalogItem.AssetType.Name] ~= CatalogItem.Id then
					Data.Clothing[CatalogItem.AssetType.Name] = CatalogItem.Id
				else
					Data.Clothing[CatalogItem.AssetType.Name] = 0
				end

				return Data
			end)
		elseif CatalogItem.AssetType == Enum.AvatarAssetType.EmoteAnimation then
			if LocalAvatar.HumanoidDescriber:GetEmote(CatalogItem.Name) == nil then
				LocalAvatar.HumanoidDescriber:SetEmote(CatalogItem.Name, { CatalogItem.Id })
			end

			LocalAvatar.HumanoidDescriber:SetEmoteEquipped(
				CatalogItem.Name,
				not (LocalAvatar.HumanoidDescriber:GetEquippedEmote(CatalogItem.Name) ~= nil)
			)
		elseif table.find(AvatarAssetTypes.Types.Animations, CatalogItem.AssetType) then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				local AnimationName = string.gsub(CatalogItem.AssetType.Name, "Animation", "", 1)
				local Animation = Data.Animations[AnimationName]
				if Animation then
					if Animation == CatalogItem.Id then
						Data.Animations[AnimationName] = 0
					else
						Data.Animations[AnimationName] = CatalogItem.Id
					end
				end

				return Data
			end)
		elseif table.find(AvatarAssetTypes.Types.BodyParts, CatalogItem.AssetType) then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				local PartName = CatalogItem.AssetType.Name
				if PartName == "DynamicHead" then
					PartName = "Head"
				end

				local BodyPart = Data.BodyParts[PartName]
				if BodyPart then
					if BodyPart == CatalogItem.Id then
						Data.BodyParts[PartName] = 0
					else
						Data.BodyParts[PartName] = CatalogItem.Id
					end
				end

				return Data
			end)
		else
			print(CatalogItem)
		end
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
			local HumanoidDescriberObject = HumanoidDescriber.new(HumanoidDescription)

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
