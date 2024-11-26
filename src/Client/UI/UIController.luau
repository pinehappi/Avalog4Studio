local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local OnyxUITheme = require(script.Parent.OnyxUITheme)

local Themer = OnyxUI.Themer

local DEFAULT_UIS = { "TopbarHUD", "PromptHUD" }

local UIController = {
	Name = "UIController",

	Scope = Fusion.scoped(Fusion),
	XPMultiplierDropdownIcons = {},
}

function UIController:MountUI(Component)
	return Themer.Theme:is(OnyxUITheme):during(function()
		local UIObject = Component(self.Scope, {
			Parent = self.AvalogUI,
		})

		return UIObject
	end)
end

function UIController:KnitStart()
	States:Start()

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = Avalog.SourceCode.Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui)
		end
	end
end

UIController.AvalogUI = UIController.Scope:New "ScreenGui" {
	Name = "AvalogUI",
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	ResetOnSpawn = false,
}

return UIController
