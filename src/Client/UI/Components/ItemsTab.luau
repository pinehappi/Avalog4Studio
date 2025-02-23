local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children
local Out = Fusion.Out
local OnChange = Fusion.OnChange

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent[".pesde"]["imavafe_onyx-ui@0.5.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
	Items: Fusion.UsedAs<{ [string]: any }>?,
	OnReachedEnd: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)
	local Items = OnyxUI.Util.Fallback(Props.Items, {})
	local OnReachedEnd = OnyxUI.Util.Fallback(Props.OnReachedEnd, function() end)

	local AbsoluteCanvasSize = Scope:Value(Vector2.new())
	local AbsoluteWindowSize = Scope:Value(Vector2.new())

	local ItemsTab = Scope:Hydrate(Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,
		Visible = Shown,
		CanvasSize = UDim2.fromOffset(0, 0),

		[Children] = {
			Scope:Frame {
				Name = "Items",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Scope:ForValues(Items, function(Use, Scope, Item)
						return OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
							return Scope:ItemButton {
								Id = Item.Id,
								Type = Item.Type,
								Visible = Item.Visible,
							}
						end)
					end),
				},
			},
			Scope:Card {
				Name = "NoItemsCard",
				ListEnabled = true,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
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
	}))) {
		[OnChange "CanvasPosition"] = function(CanvasPosition: Vector2)
			local OnReachedEndValue = Fusion.peek(OnReachedEnd)
			local AbsoluteCanvasSizeValue = Fusion.peek(AbsoluteCanvasSize)
			local AbsoluteWindowSizeValue = Fusion.peek(AbsoluteWindowSize)

			local CanvasHeight = AbsoluteCanvasSizeValue.Y - AbsoluteWindowSizeValue.Y

			if CanvasPosition.Y >= CanvasHeight then
				OnReachedEndValue()
			end
		end,
		[Out "AbsoluteCanvasSize"] = AbsoluteCanvasSize,
		[Out "AbsoluteWindowSize"] = AbsoluteWindowSize,
	}

	return ItemsTab
end
