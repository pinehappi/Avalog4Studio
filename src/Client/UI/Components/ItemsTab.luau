local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListWraps = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,

		[Children] = {

			Scope:ForValues({
				111478038776562,
				111478038776562,
				111478038776562,
				111478038776562,
				111478038776562,
				111478038776562,
				111478038776562,
			}, function(Use, Scope, AssetId)
				return OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
					return Scope:ItemButton {
						AssetId = AssetId,
					}
				end)
			end),
		},
	}))
end
