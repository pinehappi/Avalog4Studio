local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Squash = require(Avalog.Parent.Squash)

local S = Squash
local T = Squash.T

local AccessorySpec = S.record {
	AssetId = T(S.number(8)),
	AccessoryType = T(S.EnumItem(Enum.AccessoryType)),
	Order = T(S.opt(S.number(4))),
	Puffiness = T(S.opt(S.number(8))),
	IsLayered = T(S.opt(S.boolean())),
	Position = T(S.opt(S.Vector3(S.number(8)))),
	Rotation = T(S.opt(S.Vector3(S.number(8)))),
	Scale = T(S.opt(S.Vector3(S.number(8)))),
}

local EquippedEmote = S.record {
	Name = T(S.string()),
	Slot = T(S.number(4)),
}

local HumanoidDescriber = S.record {
	Accessories = T(S.array(AccessorySpec)),
	Emotes = T(S.map(S.string(), S.array(S.number(8)))),
	EquippedEmotes = T(S.array(EquippedEmote)),
	Face = T(S.number(8)),
	Scale = T(S.record {
		BodyType = T(S.number(8)),
		Depth = T(S.number(8)),
		Head = T(S.number(8)),
		Height = T(S.number(8)),
		Proportion = T(S.number(8)),
		Width = T(S.number(8)),
	}),
	Animations = T(S.record {
		Walk = T(S.number(8)),
		Run = T(S.number(8)),
		Fall = T(S.number(8)),
		Climb = T(S.number(8)),
		Swim = T(S.number(8)),
		Idle = T(S.number(8)),
		Mood = T(S.number(8)),
		Jump = T(S.number(8)),
	}),
	BodyParts = T(S.record {
		Head = T(S.number(8)),
		Torso = T(S.number(8)),
		LeftArm = T(S.number(8)),
		RightArm = T(S.number(8)),
		LeftLeg = T(S.number(8)),
		RightLeg = T(S.number(8)),
	}),
	BodyPartColors = T(S.record {
		Head = T(S.Color3()),
		Torso = T(S.Color3()),
		LeftArm = T(S.Color3()),
		RightArm = T(S.Color3()),
		LeftLeg = T(S.Color3()),
		RightLeg = T(S.Color3()),
	}),
	Clothing = T(S.record {
		Shirt = T(S.number(8)),
		TShirt = T(S.number(8)),
		Pants = T(S.number(8)),
	}),
}

return HumanoidDescriber
