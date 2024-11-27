local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Components = require(Avalog.SourceCode.Client.UI.Components)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:New "ScreenGui" {
		Name = script.Name,
		Parent = Props.Parent,

		[Children] = {
			Scope:Frame {
				Size = UDim2.fromScale(1, 1),
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListVerticalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),

				[Children] = {
					Scope:CatalogMenu {
						FlexMode = Enum.UIFlexMode.Fill,
					},
					Scope:AvatarViewport {},
				},
			},
		},
	}
end
