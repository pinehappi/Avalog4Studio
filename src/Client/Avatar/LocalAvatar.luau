local AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)
local Future = require(Avalog.Parent.Future)
local States = require(Avalog.SourceCode.Client.UI.States)

local ASSET_ACCESSORY_TYPES = {
	Hat = Enum.AccessoryType.Hat,
	HairAccessory = Enum.AccessoryType.Hair,
	FaceAccessory = Enum.AccessoryType.Face,
	NeckAccessory = Enum.AccessoryType.Neck,
	ShoulderAccessory = Enum.AccessoryType.Shoulder,
	FrontAccessory = Enum.AccessoryType.Front,
	BackAccessory = Enum.AccessoryType.Back,
	WaistAccessory = Enum.AccessoryType.Waist,

	ShirtAccessory = Enum.AccessoryType.Shirt,
	TShirtAccessory = Enum.AccessoryType.TShirt,
	SweaterAccessory = Enum.AccessoryType.Sweater,
	JacketAccessory = Enum.AccessoryType.Jacket,
	PantsAccessory = Enum.AccessoryType.Pants,
	DressSkirtAccessory = Enum.AccessoryType.DressSkirt,
	ShortsAccessory = Enum.AccessoryType.Shorts,
	LeftShoeAccessory = Enum.AccessoryType.LeftShoe,
	RightShoeAccessory = Enum.AccessoryType.RightShoe,
}

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
			for _, BundleItem in pairs(Result.Items) do
				if BundleItem.Type == "UserOutfit" then
					if Result.BundleType == "BodyParts" then
						local Success2, Result2 = Future.Try(function()
							return Players:GetHumanoidDescriptionFromOutfitId(BundleItem.Id)
						end):Await()

						if Success2 then
							LocalAvatar.HumanoidDescriber:ReadFromDescription(Result2)
						end
					elseif Result.BundleType == "AvatarAnimations" then
						local Success2, Result2 = Future.Try(function()
							return Players:GetHumanoidDescriptionFromOutfitId(BundleItem.Id)
						end):Await()

						if Success2 then
							local BundleDescriber = HumanoidDescriber.new(Result2)
							local BundleData = BundleDescriber:GetData()

							self.HumanoidDescriber:UpdateData(function(Data)
								Data.Animations = BundleData.Animations
								return Data
							end)
						end
					else
						print(Result)
					end
				end
			end
		end
	elseif Item.ItemType == "Asset" then
		local AccessoryType = ASSET_ACCESSORY_TYPES[Item.AssetType]
		if AccessoryType then
			LocalAvatar.HumanoidDescriber:ToggleAccessory({
				AssetId = Item.Id,
				AccessoryType = AccessoryType,
				Order = 1,
			})
		elseif Item.AssetType == "Face" then
			LocalAvatar.HumanoidDescriber:UpdateData(function(Data)
				Data.Face = Item.Id
				return Data
			end)
		else
			print(Item.AssetType, Item.ItemType, Item)
		end
	end

	if next(States.Services.AvatarService) ~= nil then
		States.Services.AvatarService:Update(self.HumanoidDescriber:GetData())
	end
end

function LocalAvatar:SetCharacter(Character: Model)
	if not Players.LocalPlayer:HasAppearanceLoaded() then
		Players.LocalPlayer:GetPropertyChangedSignal("HasAppearanceLoaded"):Wait()
	end

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
