local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.3"]["onyx-ui"]
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

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local ScaleProperties = {
		BodyType = Scope:Value(1),
		Proportion = Scope:Value(1),
		Height = Scope:Value(1),
		Width = Scope:Value(1),
		Depth = Scope:Value(1),
		Head = Scope:Value(1),
	}

	for Name, Value in pairs(ScaleProperties) do
		Scope:Observer(Value):onChange(function()
			LocalAvatar:UpdateScale(Name, Fusion.peek(Value))
		end)
	end

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Visible = Shown,
		CanvasSize = UDim2.new(),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		[Children] = {
			Scope:ForPairs(ScaleProperties, function(Use, Scope, Name, Value)
				return Name, Scope:SliderSetting {
					Label = Name,
					Value = Value,
				}
			end),
		},
	}))
end
