local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

local MODES = { "Marketplace", "Inventory", "Customize" }

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemsTab = require(script.Parent.ItemsTab),
		SkinTab = require(script.Parent.SkinTab),
		BuildTab = require(script.Parent.BuildTab),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local ActiveMode = Scope:Computed(function(Use)
		local ModeValue = Use(States.Catalog.Mode)
		return MODES[ModeValue]
	end)
	local ActiveCategory = Scope:Computed(function(Use)
		local ActiveModeValue = Use(ActiveMode)
		local CategoryValue = Use(States.Catalog.Category)

		return Categories[ActiveModeValue][CategoryValue]
	end)
	local ActiveTab = Scope:Computed(function(Use)
		local ActiveModeValue = Use(ActiveMode)
		local CategoryValue = Use(ActiveCategory)

		if (ActiveModeValue == "Marketplace") or (ActiveModeValue == "Inventory") then
			return "ItemsTab"
		elseif ActiveModeValue == "Customize" then
			if CategoryValue and CategoryValue.Name then
				if CategoryValue.Name == "Skin" then
					return "SkinTab"
				elseif CategoryValue.Name == "Build" then
					return "BuildTab"
				end
			end
		end

		return nil
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
			Scope:ItemsTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "ItemsTab"
				end),
			},
			Scope:SkinTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "SkinTab"
				end),
			},
			Scope:BuildTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "BuildTab"
				end),
			},
		},
	}))
end
