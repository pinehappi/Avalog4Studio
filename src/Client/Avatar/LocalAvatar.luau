local AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)
local Future = require(Avalog.Parent.Future)
local AssetAccessoryTypes = require(Avalog.SourceCode.Shared.AssetAccessoryType)

local CLOTHING_TYPES = { "Shirt", "TShirt", "Pants" }

local LocalAvatar = {
	Character = Instance.new("Model"),
	Humanoid = Instance.new("Humanoid"),
	HumanoidDescriber = HumanoidDescriber.new(Instance.new("HumanoidDescription")),
	Updated = Signal.new(),
}

function LocalAvatar:ToggleCatalogItem(Item)
	if Item.ItemType == "Bundle" then
		local Success, Result = Future.Try(function()
			return AssetService:GetBundleDetailsAsync(Item.Id)
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
	elseif Item.ItemType == "Asset" then
		local AccessoryType = AssetAccessoryTypes[Item.AssetType]
		if AccessoryType then
			LocalAvatar.HumanoidDescriber:ToggleAccessory({
				AssetId = Item.Id,
				AccessoryType = AccessoryType,
				Order = 1,
			})
		elseif Item.AssetType == "Face" then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				if Data.Face ~= Item.Id then
					Data.Face = Item.Id
				else
					Data.Face = 0
				end

				return Data
			end)
		elseif table.find(CLOTHING_TYPES, Item.AssetType) then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				if Data.Clothing[Item.AssetType] ~= Item.Id then
					Data.Clothing[Item.AssetType] = Item.Id
				else
					Data.Clothing[Item.AssetType] = 0
				end

				return Data
			end)
		elseif Item.AssetType == "EmoteAnimation" then
			if LocalAvatar.HumanoidDescriber:GetEmote(Item.Name) == nil then
				LocalAvatar.HumanoidDescriber:SetEmote(Item.Name, { Item.Id })
			end

			LocalAvatar.HumanoidDescriber:SetEmoteEquipped(
				Item.Name,
				not (LocalAvatar.HumanoidDescriber:GetEquippedEmote(Item.Name) ~= nil)
			)
		else
			print(Item)
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
