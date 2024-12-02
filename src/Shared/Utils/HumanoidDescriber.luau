local Avalog = script.Parent.Parent.Parent.Parent
local Signal = require(Avalog.Parent.Signal)
local DeepCopy = require(Avalog.SourceCode.Shared.Utils.DeepCopy)

export type AccessorySpec = {
	Order: number?,
	AssetId: number,
	AccessoryType: Enum.AccessoryType,
	Puffiness: number?,
}
export type Data = {
	Accessories: { AccessorySpec },
	Emotes: {},
	Face: number,
	Scale: {
		BodyType: number,
		Depth: number,
		Head: number,
		Height: number,
		Proportion: number,
		Width: number,
	},
	Animations: {
		Walk: number,
		Run: number,
		Fall: number,
		Climb: number,
		Swim: number,
		Idle: number,
		Mood: number,
		Jump: number,
	},
	BodyParts: {
		Head: number,
		Torso: number,
		LeftArm: number,
		RightArm: number,
		LeftLeg: number,
		RightLeg: number,
	},
	BodyPartColors: {
		Head: Color3,
		Torso: Color3,
		LeftArm: Color3,
		RightArm: Color3,
		LeftLeg: Color3,
		RightLeg: Color3,
	},
	Clothing: {
		Shirt: number,
		TShirt: number,
		Pants: number,
	},
}

local HumanoidDescriber = {
	Data = {
		Accessories = {},
		Emotes = {},
		Face = 0,
		Scale = {
			BodyType = 0,
			Depth = 0,
			Head = 0,
			Height = 0,
			Proportion = 0,
			Width = 0,
		},
		Animations = {
			Walk = 0,
			Run = 0,
			Fall = 0,
			Climb = 0,
			Swim = 0,
			Idle = 0,
			Mood = 0,
			Jump = 0,
		},
		BodyParts = {
			Head = 0,
			Torso = 0,
			LeftArm = 0,
			RightArm = 0,
			LeftLeg = 0,
			RightLeg = 0,
		},
		BodyPartColors = {
			Head = Color3.fromRGB(0, 0, 0),
			Torso = Color3.fromRGB(0, 0, 0),
			LeftArm = Color3.fromRGB(0, 0, 0),
			RightArm = Color3.fromRGB(0, 0, 0),
			LeftLeg = Color3.fromRGB(0, 0, 0),
			RightLeg = Color3.fromRGB(0, 0, 0),
		},
		Clothing = {
			Shirt = 0,
			TShirt = 0,
			Pants = 0,
		},
	},
	HumanoidDescription = Instance.new("HumanoidDescription"),

	Updated = Signal.new(),
}

function HumanoidDescriber:ToggleAccessory(Accessory: AccessorySpec)
	if self:GetAccessory(Accessory.AssetId) then
		self:RemoveAccessory(Accessory.AssetId)
	else
		self:AddAccessory(Accessory)
	end
end

function HumanoidDescriber:AddAccessory(Accessory: AccessorySpec)
	local AccessoryIndex = self:GetAccessory(Accessory.AssetId)

	if AccessoryIndex == nil then
		self:UpdateData(function(OldData)
			table.insert(OldData.Accessories, Accessory)
		end)
	end
end

function HumanoidDescriber:RemoveAccessory(AssetId: number)
	local AccessoryIndex = self:GetAccessory(AssetId)

	if AccessoryIndex ~= nil then
		self:UpdateData(function(OldData)
			table.remove(OldData.Accessories, AccessoryIndex)
			return OldData
		end)
	end
end

function HumanoidDescriber:GetAccessory(AssetId: number): (number?, AccessorySpec?)
	local Data = self:GetData()

	for Index, Accessory: AccessorySpec in ipairs(Data.Accessories) do
		if Accessory.AssetId == AssetId then
			return Index, Accessory
		end
	end

	return nil
end

function HumanoidDescriber:ReadFromDescription(HumanoidDescription: HumanoidDescription)
	self.HumanoidDescription = HumanoidDescription

	local NewData: Data = {
		Face = self.HumanoidDescription.Face,
		Accessories = self.HumanoidDescription:GetAccessories(true),
		Emotes = self.HumanoidDescription:GetEmotes(),
		Scale = {
			BodyType = self.HumanoidDescription.BodyTypeScale,
			Depth = self.HumanoidDescription.DepthScale,
			Head = self.HumanoidDescription.HeadScale,
			Height = self.HumanoidDescription.HeightScale,
			Proportion = self.HumanoidDescription.ProportionScale,
			Width = self.HumanoidDescription.WidthScale,
		},
		BodyParts = {
			Head = self.HumanoidDescription.Head,
			Torso = self.HumanoidDescription.Torso,
			LeftLeg = self.HumanoidDescription.LeftLeg,
			RightLeg = self.HumanoidDescription.RightLeg,
			LeftArm = self.HumanoidDescription.LeftArm,
			RightArm = self.HumanoidDescription.RightArm,
		},
		Animations = {
			Idle = self.HumanoidDescription.IdleAnimation,
			Walk = self.HumanoidDescription.WalkAnimation,
			Run = self.HumanoidDescription.RunAnimation,
			Fall = self.HumanoidDescription.FallAnimation,
			Jump = self.HumanoidDescription.JumpAnimation,
			Mood = self.HumanoidDescription.MoodAnimation,
			Swim = self.HumanoidDescription.SwimAnimation,
		},
		Clothing = {
			Shirt = self.HumanoidDescription.Shirt,
			TShirt = self.HumanoidDescription.GraphicTShirt,
			Pants = self.HumanoidDescription.Pants,
		},
		BodyPartColors = {
			HeadColor = self.HumanoidDescription.HeadColor,
			TorsoColor = self.HumanoidDescription.TorsoColor,
			LeftLegColor = self.HumanoidDescription.LeftLegColor,
			RightLegColor = self.HumanoidDescription.RightLegColor,
			LeftArmColor = self.HumanoidDescription.LeftArmColor,
			RightArmColor = self.HumanoidDescription.RightArmColor,
		},
	}

	self:UpdateData(function()
		return NewData
	end)
end

function HumanoidDescriber:_UpdateHumanoidDescription()
	local Data = self:GetData()
	local Properties = {
		Face = Data.Face,

		BodyTypeScale = Data.Scale.BodyType,
		DepthScale = Data.Scale.Depth,
		HeadScale = Data.Scale.Head,
		HeightScale = Data.Scale.Height,
		ProportionScale = Data.Scale.Proportion,
		WidthScale = Data.Scale.Width,

		WalkAnimation = Data.Animations.Walk,
		RunAnimation = Data.Animations.Run,
		FallAnimation = Data.Animations.Fall,
		ClimbAnimation = Data.Animations.Climb,
		SwimAnimation = Data.Animations.Swim,
		IdleAnimation = Data.Animations.Idle,
		MoodAnimation = Data.Animations.Mood,
		JumpAnimation = Data.Animations.Jump,

		Head = Data.BodyParts.Head,
		Torso = Data.BodyParts.Torso,
		LeftArm = Data.BodyParts.LeftArm,
		RightArm = Data.BodyParts.RightArm,
		LeftLeg = Data.BodyParts.LeftLeg,
		RightLeg = Data.BodyParts.RightLeg,

		HeadColor = Data.BodyPartColors.Head,
		TorsoColor = Data.BodyPartColors.Torso,
		LeftArmColor = Data.BodyPartColors.LeftArm,
		RightArmColor = Data.BodyPartColors.RightArm,
		LeftLegColor = Data.BodyPartColors.LeftLeg,
		RightLegColor = Data.BodyPartColors.RightLeg,

		Shirt = Data.Clothing.Shirt,
		GraphicTShirt = Data.Clothing.TShirt,
		Pants = Data.Clothing.Pants,
	}

	for Name, Value in ipairs(Properties) do
		self.HumanoidDescription[Name] = Value
	end

	self.HumanoidDescription:SetAccessories(Data.Accessories, true)
	self.HumanoidDescription:SetEmotes(Data.Emotes)
end

function HumanoidDescriber:UpdateData(ModifierCallback: (Data) -> ())
	local OldData = self:GetData()
	local NewData = self:GetData()

	ModifierCallback(NewData)

	if NewData ~= nil then
		self.Data = NewData

		self:_UpdateHumanoidDescription(NewData)

		self.Updated:Fire(OldData, NewData)
	else
		assert(false, "Data was not returned.")
	end
end

function HumanoidDescriber:GetData(): Data
	return DeepCopy(self.Data)
end

function HumanoidDescriber:Destroy()
	self.Updated:Destroy()
end

function HumanoidDescriber.new(HumanoidDescription: HumanoidDescription)
	local self = table.clone(HumanoidDescriber)

	self.HumanoidDescription = HumanoidDescription
	self:ReadFromDescription(HumanoidDescription)

	return self
end

return HumanoidDescriber
