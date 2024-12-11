local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
	Items: Fusion.UsedAs<{ [string]: any }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)
	local Items = OnyxUI.Util.Fallback(Props.Items, {})

	local ItemsTab = Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListWraps = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,
		Visible = Shown,
		CanvasSize = UDim2.fromOffset(0, 0),

		[Children] = {
			Scope:ForValues(Items, function(Use, Scope, Item)
				return OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
					return Scope:ItemButton {
						Id = Item.Id,
						Type = Item.Type,
						Visible = Item.Visible,
					}
				end)
			end),
			Scope:Card {
				Name = "NoItemsCard",
				FlexMode = Enum.UIFlexMode.Fill,
				ListEnabled = true,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				BackgroundTransparency = 1,
				Visible = Scope:Computed(function(Use)
					local ItemsValue = Use(Items)
					return #ItemsValue == 0
				end),

				[Children] = {
					Scope:Image {
						Image = "rbxassetid://10480493542",
						BackgroundTransparency = 1,
					},
					Scope:Text {
						Text = "No items to show",
						TextWrapped = false,
					},
				},
			},
		},
	}))

	return ItemsTab
end
