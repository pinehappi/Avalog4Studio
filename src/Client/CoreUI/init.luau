local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local Avalog = script.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Config = require(Avalog.Config)

local ITEM_HANDLERS = {
	Backpack = Enum.CoreGuiType.Backpack,
	PlayerList = Enum.CoreGuiType.PlayerList,
	Emotes = Enum.CoreGuiType.EmotesMenu,
	Captures = Enum.CoreGuiType.Captures,
	Chat = Enum.CoreGuiType.Chat,
	TouchControls = function(Enabled: boolean)
		GuiService.TouchControlsEnabled = Enabled
	end,
}

local Scope = Fusion.scoped(Fusion)

local CoreUI = {}

Scope:Observer(States.Open):onChange(function()
	local OpenValue = Fusion.peek(States.Open)

	for _, CoreGuiItem in ipairs(Config:Get().HiddenCoreGui) do
		local ItemHandler = ITEM_HANDLERS[CoreGuiItem]

		if typeof(ItemHandler) == "EnumItem" then
			StarterGui:SetCoreGuiEnabled(ItemHandler, not OpenValue)
		elseif typeof(ItemHandler) == "function" then
			ItemHandler(not OpenValue)
		end
	end
end)

return CoreUI
