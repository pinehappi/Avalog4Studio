local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local OnyxUITheme = require(script.Parent.OnyxUITheme)

local AvalogMenu = require(script.Parent.ScreenGuis.AvalogMenu)

local Themer = OnyxUI.Themer

local UIController = {
	Name = "UIController",

	Scope = Fusion.scoped(Fusion),
	XPMultiplierDropdownIcons = {},
}

function UIController:KnitStart()
	States:Start()

	Themer.Theme:is(OnyxUITheme):during(function()
		AvalogMenu(self.Scope, {
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		})
	end)
end

return UIController
