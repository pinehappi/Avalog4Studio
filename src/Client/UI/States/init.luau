local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local Loader = require(Avalog.Parent.Loader)

local Scope = Fusion.scoped(Fusion)

local States = {
	Services = {},
	Catalog = {
		Mode = Scope:Value(1),
		Category = Scope:Value(1),
		SubCategory = Scope:Value(1),
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
