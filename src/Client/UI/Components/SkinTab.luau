local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.2"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)
local SliderSetting = require(script.Parent.SliderSetting)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		SliderSetting = SliderSetting,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Shown, false))

	States.Catalog.Mode:set(3)
	States.Catalog.Category:set(2)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListWraps = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Visible = Shown,

		[Children] = {
			Scope:Heading {
				Text = "hi",
			},
			Scope:SliderSetting {
				Label = "Hue",
				Value = Scope:Value(1),
			},
		},
	}))
end
