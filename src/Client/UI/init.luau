local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local StateExtensions = require(Avalog.SourceCode.Client.UI.StateExtensions)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local States = require(script.States)
local Config = require(Avalog.Config)

local AvalogMenu = require(script.ScreenGuis.AvalogMenu)

local UIService = {
	Scope = Fusion.scoped(Fusion),
}

function UIService:Start()
	StateExtensions:Initialize()
	StateExtensions:Start()

	States.Theme:set(Config:Get().Theme)

	OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
		AvalogMenu(self.Scope, {
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		})
	end)
end

return UIService
