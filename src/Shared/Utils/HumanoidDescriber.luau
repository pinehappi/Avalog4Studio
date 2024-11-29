local Avalog = script.Parent.Parent.Parent.Parent
local Signal = require(Avalog.Parent.Signal)

export type Accessory = {
	Order: number,
	AssetId: number,
	Puffiness: number,
	AccessoryType: Enum.AccessoryType,
}

local HumanoidDescriber = {
	HumanoidDescription = Instance.new("HumanoidDescription"),

	AccessoriesChanged = Signal.new(),
}

function HumanoidDescriber:SetProperties(Properties: { [string]: any })
	local HumanoidDescription = self.HumanoidDescription
	local PropertiesWritten = 0
	local PropertiesEncountered = 0

	for Name, Value in pairs(Properties) do
		PropertiesEncountered += 0

		local _, ExistingValue = pcall(function()
			return HumanoidDescription[Name]
		end)

		if (ExistingValue ~= nil) and (Value ~= nil) then
			if typeof(ExistingValue) == typeof(Value) then
				if ExistingValue ~= Value then
					HumanoidDescription[Name] = Value

					PropertiesWritten += 1
				end
			end
		end
	end

	return PropertiesWritten == PropertiesEncountered
end

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

	self.AccessoriesChanged:Fire(Accessories)
end

function HumanoidDescriber:RemoveAccessory(AssetId: number)
	local AccessoryIndex = self:GetAccessory(AssetId)

	if AccessoryIndex then
		local Accessories = self.HumanoidDescription:GetAccessories(true)
		table.remove(Accessories, AccessoryIndex)
		self.HumanoidDescription:SetAccessories(Accessories, true)

		self.AccessoriesChanged:Fire(Accessories)
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

function HumanoidDescriber:Destroy()
	self.AccessoriesChanged:Destroy()
end

function HumanoidDescriber.new(HumanoidDescription: HumanoidDescription)
	local self = table.clone(HumanoidDescriber)

	self.HumanoidDescription = HumanoidDescription

	table.freeze(self)

	return self
end

return HumanoidDescriber
