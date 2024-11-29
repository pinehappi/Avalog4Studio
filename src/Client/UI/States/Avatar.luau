local Avalog = script.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(Avalog.SourceCode.Client.UI.States)

local PROPERTY_VALUE_BINDS = {
	Face = States.Avatar.Face,

	BodyTypeScale = States.Avatar.Scale.BodyType,
	DepthScale = States.Avatar.Scale.Depth,
	HeadScale = States.Avatar.Scale.Head,
	HeightScale = States.Avatar.Scale.Height,
	ProportionScale = States.Avatar.Scale.Proportion,
	WidthScale = States.Avatar.Scale.Width,

	Head = States.Avatar.BodyParts.Head,
	Torso = States.Avatar.BodyParts.Torso,
	LeftLeg = States.Avatar.BodyParts.LeftLeg,
	RightLeg = States.Avatar.BodyParts.RightLeg,
	LeftArm = States.Avatar.BodyParts.LeftArm,
	RightArm = States.Avatar.BodyParts.RightArm,

	IdleAnimation = States.Avatar.Animations.Idle,
	WalkAnimation = States.Avatar.Animations.Walk,
	RunAnimation = States.Avatar.Animations.Run,
	FallAnimation = States.Avatar.Animations.Fall,
	JumpAnimation = States.Avatar.Animations.Jump,
	MoodAnimation = States.Avatar.Animations.Mood,
	SwimAnimation = States.Avatar.Animations.Swim,

	Shirt = States.Avatar.Clothing.Shirt,
	GraphicTShirt = States.Avatar.Clothing.TShirt,
	Pants = States.Avatar.Clothing.Pants,

	HeadColor = States.Avatar.BodyPartColors.Head,
	TorsoColor = States.Avatar.BodyPartColors.Torso,
	LeftLegColor = States.Avatar.BodyPartColors.LeftLeg,
	RightLegColor = States.Avatar.BodyPartColors.RightLeg,
	LeftArmColor = States.Avatar.BodyPartColors.LeftArm,
	RightArmColor = States.Avatar.BodyPartColors.RightArm,
}

local Avatar = {}

function Avatar:_HandleAvatar()
	local HumanoidDescriber = LocalAvatar.HumanoidDescriber
	local HumanoidDescription = HumanoidDescriber.HumanoidDescription

	self:_BindProperties()

	HumanoidDescriber.AccessoriesChanged:Connect(function()
		self:_UpdateAccessories()
	end)
	self:_UpdateAccessories()

	HumanoidDescription.EmotesChanged:Connect(function()
		self:_UpdateEmotes()
	end)
	self:_UpdateEmotes()
end

function Avatar:_BindProperties()
	for Property, Value in pairs(PROPERTY_VALUE_BINDS) do
		local function UpdateValue()
			Value:set(LocalAvatar.HumanoidDescriber.HumanoidDescription[Property])
		end

		LocalAvatar.HumanoidDescriber.HumanoidDescription:GetPropertyChangedSignal(Property):Connect(function()
			UpdateValue()
		end)

		UpdateValue()
	end
end

function Avatar:_UpdateAccessories()
	States.Avatar.Accessories:set(LocalAvatar.HumanoidDescriber.HumanoidDescription:GetAccessories(true))
end

function Avatar:_UpdateEmotes()
	States.Avatar.Emotes:set(LocalAvatar.HumanoidDescriber.HumanoidDescription:GetEquippedEmotes())
end

function Avatar:Start()
	LocalAvatar.Updated:Connect(function()
		self:_HandleAvatar()
	end)

	self:_HandleAvatar()
end

return Avatar
