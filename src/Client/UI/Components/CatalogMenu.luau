local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		Tabs = require(script.Parent.Tabs),
		ItemButton = require(script.Parent.ItemButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "CatalogMenu",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Base.Main,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		[Children] = {
			Scope:Frame {
				Name = "NavigationBar",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				ListVerticalAlignment = Enum.VerticalAlignment.Center,

				[Children] = {
					Scope:IconButton {
						Name = "ExitButton",
						Image = "rbxassetid://13846120661",
						SizeVariant = "ExtraLarge",
						Style = "Ghost",
						Color = Theme.Colors.BaseContent.Main,
						PaddingLeft = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingRight = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingTop = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingBottom = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
					},
					Scope:SwapInput {
						Name = "ModeSwapper",
						Options = { "Marketplace", "Inventory" },
					},
					Scope:IconButton {
						Name = "SearchButton",
						Image = "rbxassetid://13850026502",
						SizeVariant = "ExtraLarge",
						Style = "Ghost",
						Color = Theme.Colors.BaseContent.Main,
						PaddingLeft = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingRight = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingTop = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingBottom = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
					},
				},
			},
			Scope:Frame {
				Name = "Categories",
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Tabs {
						Options = {
							"Characters",
							"Head & Body",
							"Clothing",
							"Accessories",
							"Emotes",
							"Animation",
						},
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Neutral.Main,
					},
					Scope:Tabs {
						Options = { "Head", "Face", "Neck", "Shoulder", "Front", "Back", "Waist", "Gear" },
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Base.Dark,
					},
				},
			},
			Scope:Scroller {
				Name = "Items",
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				FlexMode = Enum.UIFlexMode.Fill,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ScrollBarImageColor3 = Theme.Colors.Neutral.Light,

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
						return Scope:ItemButton {
							AssetId = AssetId,
						}
					end),
				},
			},
		},
	}))
end
