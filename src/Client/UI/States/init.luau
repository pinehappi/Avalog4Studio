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
		Data = Scope:Value(nil),
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
