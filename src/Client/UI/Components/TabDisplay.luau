local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

local MODES = { "Marketplace", "Inventory", "Build" }

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemsTab = require(script.Parent.ItemsTab),
		SkinTab = require(script.Parent.SkinTab),
		BuildTab = require(script.Parent.BuildTab),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local ActiveMode = Scope:Computed(function(Use)
		return MODES[Use(States.Catalog.Mode)]
	end)
	local ActiveCategory = Scope:Computed(function(Use)
		local ActiveModeValue = Use(ActiveMode)
		local CategoryValue = Use(States.Catalog.Category)

		return Categories[ActiveModeValue][CategoryValue]
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "Tab",
		FlexMode = Enum.UIFlexMode.Fill,
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListVerticalFlex = Enum.UIFlexAlignment.Fill,
		ClipsDescendants = true,

		[Children] = {
			OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
				return Scope:Computed(function(Use)
					local ActiveModeValue = Use(ActiveMode)
					local CategoryValue = Use(ActiveCategory)

					if (ActiveModeValue == "Marketplace") or (ActiveModeValue == "Inventory") then
						return Scope:ItemsTab {}
					elseif ActiveModeValue == "Build" then
						if CategoryValue and CategoryValue.Name then
							if CategoryValue.Name == "Skin" then
								return Scope:SkinTab {}
							elseif CategoryValue.Name == "Build" then
								return Scope:BuildTab {}
							end
						end
					end

					return nil
				end)
			end),
		},
	}))
end
