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
		Name = "Menu",
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
						BackgroundColor3 = Theme.Colors.Neutral.Dark,
					},
				},
			},
			Scope:Frame {
				Name = "Items",
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				FlexMode = Enum.UIFlexMode.Fill,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,

				[Children] = {
					Scope:ItemButton {
						AssetId = 111478038776562,
					},
					Scope:ItemButton {
						AssetId = 11999247,
						Equipped = true,
					},
				},
			},
		},
	}))
end
