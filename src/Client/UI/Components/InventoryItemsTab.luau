local AvatarEditorService = game:GetService("AvatarEditorService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)

local ItemsTab = require(script.Parent.ItemsTab)

export type Props = ItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		ItemsTab = require(script.Parent.ItemsTab),
	})

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	Scope:Observer(Shown):onChange(function()
		local ShownValue = Fusion.peek(Shown)
		local AccessAllowedValue = Fusion.peek(States.Inventory.AccessAllowed)

		if ShownValue and not AccessAllowedValue then
			AvatarEditorService:PromptAllowInventoryReadAccess()
		end
	end)
	AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(Result)
		local ShownValue = Fusion.peek(Shown)
		local ModeValue = Fusion.peek(States.Catalog.Mode)

		if ShownValue and (Result ~= Enum.AvatarPromptResult.Success) then
			States.Catalog.Mode:set(ModeValue + 1)
		end
	end)

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		-- Items = Scope:ForValues(AssetIds, function(Use, Scope, AssetId)
		-- 	return {
		-- 		Id = AssetId,
		-- 		Type = Enum.AvatarItemType.Asset,
		-- 	}
		-- end),
	}))
end
