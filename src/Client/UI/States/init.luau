local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local Loader = require(Avalog.Parent.Loader)

local Scope = Fusion.scoped(Fusion)

local function UnloadedService(): { [any]: any }
	return {}
end

local States = {
	Services = {
		AvatarService = UnloadedService(),
	},
	Catalog = {
		Searching = Scope:Value(false),
		SearchQuery = Scope:Value(""),
		Mode = Scope:Value(1),
		Category = Scope:Value(1),
		SubCategory = Scope:Value(1),
	},
	Avatar = {
		Accessories = Scope:Value({}),
		Emotes = Scope:Value({}),
		Face = Scope:Value(0),
		Scale = {
			BodyType = Scope:Value(0),
			Depth = Scope:Value(0),
			Head = Scope:Value(0),
			Height = Scope:Value(0),
			Proportion = Scope:Value(0),
			Width = Scope:Value(0),
		},
		Animations = {
			Walk = Scope:Value(0),
			Run = Scope:Value(0),
			Fall = Scope:Value(0),
			Climb = Scope:Value(0),
			Swim = Scope:Value(0),
			Idle = Scope:Value(0),
			Mood = Scope:Value(0),
			Jump = Scope:Value(0),
		},
		BodyParts = {
			Head = Scope:Value(0),
			Torso = Scope:Value(0),
			LeftArm = Scope:Value(0),
			RightArm = Scope:Value(0),
			LeftLeg = Scope:Value(0),
			RightLeg = Scope:Value(0),
		},
		BodyPartColors = {
			Head = Scope:Value(Color3.fromRGB(0, 0, 0)),
			Torso = Scope:Value(Color3.fromRGB(0, 0, 0)),
			LeftArm = Scope:Value(Color3.fromRGB(0, 0, 0)),
			RightArm = Scope:Value(Color3.fromRGB(0, 0, 0)),
			LeftLeg = Scope:Value(Color3.fromRGB(0, 0, 0)),
			RightLeg = Scope:Value(Color3.fromRGB(0, 0, 0)),
		},
		Clothing = {
			Shirt = Scope:Value(0),
			TShirt = Scope:Value(0),
			Pants = Scope:Value(0),
		},
	},
	Open = Scope:Value(false),
}

function States:_StartExtensions()
	Loader.SpawnAll(Loader.LoadChildren(script), "Start")
end

function States:_InitializeExtensions()
	Loader.LoadChildren(script)
end

function States:Start()
	self:_InitializeExtensions()
	self:_StartExtensions()
end

return States
