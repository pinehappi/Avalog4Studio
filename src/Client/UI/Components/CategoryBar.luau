local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local CategoriesToNames = require(Avalog.SourceCode.Shared.Categories.CategoriesToNames)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

local MODES = { "Marketplace", "Inventory", "Build" }

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		Tabs = require(script.Parent.Tabs),
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
		Name = script.Name,
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Tabs {
				Name = "Categories",
				Options = Scope:Computed(function(Use)
					local ActiveModeValue = Use(ActiveMode)

					return CategoriesToNames(Categories[ActiveModeValue])
				end),
				Selection = States.Catalog.Category,
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Colors.Neutral.Dark,
				AutomaticSize = Enum.AutomaticSize.Y,
			},
			Scope:Tabs {
				Name = "SubCategories",
				Options = Scope:Computed(function(Use)
					local ActiveCategoryValue = Use(ActiveCategory)

					return CategoriesToNames(ActiveCategoryValue.SubCategories or {})
				end),
				Selection = States.Catalog.SubCategory,
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Scope:Computed(function(Use)
					local ActiveCategoryValue = Use(ActiveCategory)

					return #CategoriesToNames(ActiveCategoryValue.SubCategories or {}) > 0
				end),
			},
		},
	}))
end
