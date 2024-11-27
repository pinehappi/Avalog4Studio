local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local OnyxUITheme = require(script.Parent.Parent.OnyxUITheme)
local States = require(Avalog.SourceCode.Client.UI.States)

local AvalogMenu = require(script.Parent.AvalogMenu)

return function(Target: Instance)
	local Scope = Fusion.scoped(Fusion, {
		AvalogMenu = AvalogMenu,
	})

	States.Open:set(true)

	OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
		return Scope:AvalogMenu {
			Parent = Target,
		}
	end)

	return function()
		Scope:doCleanup()
	end
end
