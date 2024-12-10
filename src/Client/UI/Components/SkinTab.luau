local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Avalog = script.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(ReplicatedStorage.Avalog.Packages.Avalog.SourceCode.Client.Avatar.LocalAvatar)
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

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	States.Catalog.Mode:set(3)
	States.Catalog.Category:set(2)

	local Hue = Scope:Value(1)
	local Saturation = Scope:Value(1)
	local Brightness = Scope:Value(1)

	-- Scope:Observer(States.Avatar.Data):onChange(function()
	-- 	local DataValue = Fusion.peek(States.Avatar.Data)
	-- 	local HeadColor: Color3 = DataValue.BodyPartColors.Head
	-- 	local HueValue, SaturationValue, BrightnessValue = HeadColor:ToHSV()

	-- 	Hue:set(HueValue)
	-- 	Saturation:set(SaturationValue)
	-- 	Brightness:set(BrightnessValue)
	-- end)

	local function UpdateColor()
		local HueValue = Fusion.peek(Hue)
		local SaturationValue = Fusion.peek(Saturation)
		local BrightnessValue = Fusion.peek(Brightness)

		LocalAvatar:SetColor(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
	end
	Scope:Observer(Hue):onChange(function()
		UpdateColor()
	end)
	Scope:Observer(Saturation):onChange(function()
		UpdateColor()
	end)
	Scope:Observer(Brightness):onChange(function()
		UpdateColor()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListWraps = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Visible = Shown,

		[Children] = {
			Scope:SliderSetting {
				Label = "Hue",
				Value = Hue,
			},
			Scope:SliderSetting {
				Label = "Saturation",
				Value = Saturation,
			},
			Scope:SliderSetting {
				Label = "Brightness",
				Value = Brightness,
			},
		},
	}))
end
