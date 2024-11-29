export type Accessory = {
	Order: number,
	AssetId: number,
	Puffiness: number,
	AccessoryType: Enum.AccessoryType,
}

local HumanoidDescriber = {
	HumanoidDescription = Instance.new("HumanoidDescription"),
}

function HumanoidDescriber:ToggleAccessory(Accessory: Accessory)
	if self:GetAccessory(Accessory.AssetId) then
		self:RemoveAccessory(Accessory.AssetId)
	else
		self:AddAccessory(Accessory)
	end
end

function HumanoidDescriber:AddAccessory(Accessory: Accessory)
	local Accessories = self.HumanoidDescription:GetAccessories(true)
	table.insert(Accessories, Accessory)
	self.HumanoidDescription:SetAccessories(Accessories, true)
end

function HumanoidDescriber:RemoveAccessory(AssetId: number)
	local AccessoryIndex = self:GetAccessory(AssetId)

	if AccessoryIndex then
		local Accessories = self.HumanoidDescription:GetAccessories(true)
		table.remove(Accessories, AccessoryIndex)
		self.HumanoidDescription:SetAccessories(Accessories, true)
	end
end

function HumanoidDescriber:GetAccessory(AssetId: number): (number?, Accessory?)
	local Accessories = self.HumanoidDescription:GetAccessories(true)

	for Index, Accessory: Accessory in ipairs(Accessories) do
		if Accessory.AssetId == AssetId then
			return Index, Accessory
		end
	end

	return nil
end

function HumanoidDescriber.New(HumanoidDescription: HumanoidDescription)
	local self = table.clone(HumanoidDescriber)

	self.HumanoidDescription = HumanoidDescription

	table.freeze(self)

	return self
end

return HumanoidDescriber
