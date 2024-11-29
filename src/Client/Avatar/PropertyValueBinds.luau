local Avalog = script.Parent.Parent.Parent.Parent
local States = require(Avalog.SourceCode.Client.UI.States)
local Fusion = require(Avalog.Parent.Fusion)

local PropertyValueBinds = {
	Binds = {
		Face = {
			Face = States.Avatar.Face,
		},
		Scale = {
			BodyTypeScale = States.Avatar.Scale.BodyType,
			DepthScale = States.Avatar.Scale.Depth,
			HeadScale = States.Avatar.Scale.Head,
			HeightScale = States.Avatar.Scale.Height,
			ProportionScale = States.Avatar.Scale.Proportion,
			WidthScale = States.Avatar.Scale.Width,
		},
		BodyParts = {
			Head = States.Avatar.BodyParts.Head,
			Torso = States.Avatar.BodyParts.Torso,
			LeftLeg = States.Avatar.BodyParts.LeftLeg,
			RightLeg = States.Avatar.BodyParts.RightLeg,
			LeftArm = States.Avatar.BodyParts.LeftArm,
			RightArm = States.Avatar.BodyParts.RightArm,
		},
		Animations = {
			IdleAnimation = States.Avatar.Animations.Idle,
			WalkAnimation = States.Avatar.Animations.Walk,
			RunAnimation = States.Avatar.Animations.Run,
			FallAnimation = States.Avatar.Animations.Fall,
			JumpAnimation = States.Avatar.Animations.Jump,
			MoodAnimation = States.Avatar.Animations.Mood,
			SwimAnimation = States.Avatar.Animations.Swim,
		},
		Clothing = {
			Shirt = States.Avatar.Clothing.Shirt,
			GraphicTShirt = States.Avatar.Clothing.TShirt,
			Pants = States.Avatar.Clothing.Pants,
		},
		BodyPartColors = {
			HeadColor = States.Avatar.BodyPartColors.Head,
			TorsoColor = States.Avatar.BodyPartColors.Torso,
			LeftLegColor = States.Avatar.BodyPartColors.LeftLeg,
			RightLegColor = States.Avatar.BodyPartColors.RightLeg,
			LeftArmColor = States.Avatar.BodyPartColors.LeftArm,
			RightArmColor = States.Avatar.BodyPartColors.RightArm,
		},
	},
}

function PropertyValueBinds:Combine(
	BindingLists: { { [string]: Fusion.Value<Fusion.Scope<any>, any> } }
): { [string]: Fusion.Value<Fusion.Scope<any>, any> }
	local Combined = {}

	for _, BindingList in ipairs(BindingLists) do
		for Property, Value in pairs(BindingList) do
			Combined[Property] = Value
		end
	end

	return Combined
end

function PropertyValueBinds:Flatten(
	BindingDictionaries: { [string]: { [string]: Fusion.Value<Fusion.Scope<any>, any> } }
)
	local Flattened = {}

	for _, List in pairs(BindingDictionaries) do
		table.insert(Flattened, List)
	end

	return Flattened
end

PropertyValueBinds.Binds.All = PropertyValueBinds:Combine(PropertyValueBinds:Flatten(PropertyValueBinds.Binds))

return PropertyValueBinds
