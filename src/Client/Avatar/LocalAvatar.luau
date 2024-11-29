local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)

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
	print(Item.AssetType)

	if Item.ItemType == "Bundle" then
		print("bundle")
	elseif Item.ItemType == "Asset" then
		local AccessoryType = ASSET_ACCESSORY_TYPES[Item.AssetType]
		if AccessoryType then
			LocalAvatar.HumanoidDescriber:ToggleAccessory({
				AssetId = Item.Id,
				AccessoryType = AccessoryType,
				Order = 1,
			})
		else
			-- LocalAvatar.HumanoidDescriber:SetProperties({
			-- 	AssetId = Item.Id,
			-- 	AccessoryType = AccessoryType,
			-- 	Order = 1,
			-- })
		end
	end
end

function LocalAvatar:SetCharacter(Character: Model)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		local HumanoidDescription = Humanoid:GetAppliedDescription()
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
