local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(Avalog.SourceCode.Client.UI.States)

local ItemsTab = require(script.Parent.ItemsTab)

export type Props = ItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		ItemsTab = require(script.Parent.ItemsTab),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:ForValues(States.Avatar.AssetIds, function(Use, Scope, AssetId)
			print(AssetId)
			return {
				AssetId = AssetId,
				Name = AssetId,
				Type = Enum.AvatarItemType.Asset,
			}
		end),
	}))
end
