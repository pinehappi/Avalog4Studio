local Workspace = game:GetService("Workspace")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local States = require(script.Parent.Parent.States)

local Out = Fusion.Out

local Scope = Fusion.scoped(Fusion)

local Screen = {}

Scope:Hydrate(Workspace.CurrentCamera) {
	[Out "ViewportSize"] = States.Screen.Resolution,
}

return Screen
