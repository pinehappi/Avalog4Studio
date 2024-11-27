local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Image(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		MaxSize = Scope:Computed(function(Use)
			return Vector2.new(Use(Theme.Spacing["24"]), math.huge)
		end),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Base.Dark,
		Image = "rbxassetid://140363116814273",
		ScaleType = Enum.ScaleType.Crop,
		AutomaticSize = Enum.AutomaticSize.XY,

		[Children] = {
			Scope:Frame {
				Name = "Contents",
				Size = UDim2.fromScale(1, 1),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),

				[Children] = {
					Scope:Frame {
						Name = "TopControls",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:Button {
								Content = { "rbxassetid://13846738861", "Buy" },
								SizeVariant = "Large",
							},
							Scope:Button {
								Content = { "rbxassetid://13846852950", "Done" },
								Color = Theme.Colors.Success.Main,
								SizeVariant = "Large",
							},
						},
					},
					Scope:Frame {
						Name = "BottomControls",
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.fromScale(0.5, 1),
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						Scale = 1.25,

						[Children] = {
							Scope:IconButton {
								Image = "rbxassetid://13846120661",
								SizeVariant = "ExtraLarge",
							},
							Scope:IconButton {
								Image = "rbxassetid://13847364382",
								SizeVariant = "ExtraLarge",
								Color = Theme.Colors.Error.Main,
							},
							Scope:IconButton {
								Image = "rbxassetid://13846158505",
								SizeVariant = "ExtraLarge",
							},
						},
					},
				},
			},
		},
	}))
end
