local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Components = require(Avalog.SourceCode.Client.UI.Components)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local GroupTransparency = Scope:Spring(
		Scope:Computed(function(Use)
			return (Use(States.Open) and 0) or 1
		end),
		Theme.SpringSpeed["1.5"],
		Theme.SpringDampening["1.5"]
	)
	local Enabled = Scope:Computed(function(Use)
		local GroupTransparencyValue = Use(GroupTransparency)
		return GroupTransparencyValue < 1
	end)

	return Scope:New "ScreenGui" {
		Name = script.Name,
		Parent = Props.Parent,
		DisplayOrder = 9,
		Enabled = Enabled,

		[Children] = {
			Scope:New "ScreenGui" {
				Name = "Backdrop",
				DisplayOrder = 9 - 1,
				ScreenInsets = Enum.ScreenInsets.None,

				[Children] = {
					Scope:Frame {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Theme.Colors.Neutral.Dark,
						BackgroundTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								return (Use(States.Open) and 0) or 1
							end),
							Theme.SpringSpeed["1.5"],
							Theme.SpringDampening["1.5"]
						),
						Scale = Scope:Spring(
							Scope:Computed(function(Use)
								return (Use(States.Open) and 1) or 0.75
							end),
							Theme.SpringSpeed["1.5"],
							Theme.SpringDampening["1.5"]
						),
						Active = States.Open,
						Interactable = States.Open,
					},
				},
			},
			Scope:Group {
				Name = "Menu",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				AutomaticSize = Enum.AutomaticSize.None,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListVerticalFlex = Enum.UIFlexAlignment.Fill,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),
				GroupTransparency = GroupTransparency,
				Scale = Scope:Spring(
					Scope:Computed(function(Use)
						return (Use(States.Open) and 1) or 0.75
					end),
					Theme.SpringSpeed["1.5"],
					Theme.SpringDampening["1.5"]
				),
				Active = States.Open,
				Interactable = States.Open,

				[Children] = {
					Scope:CatalogMenu {},
					Scope:AvatarViewport {},
				},
			},
		},
	}
end
