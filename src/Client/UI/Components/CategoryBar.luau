local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local CategoriesToNames = require(Avalog.SourceCode.Shared.Categories.CategoriesToNames)
local Navigation = require(Avalog.SourceCode.Client.UI.States.Extensions.Navigation)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.1"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		Tabs = require(script.Parent.Tabs),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	Scope:Observer(States.Catalog.Mode):onChange(function()
		States.Catalog.Category:set(1)
		States.Catalog.SubCategory:set(1)
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
					local ModeValue = Use(Navigation.Mode)

					return CategoriesToNames(Categories[ModeValue])
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
					local CategoryValue = Use(Navigation.Category)

					return CategoriesToNames(CategoryValue.SubCategories or {})
				end),
				Selection = States.Catalog.SubCategory,
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Scope:Computed(function(Use)
					local CategoryValue = Use(Navigation.Category)

					return #CategoriesToNames(CategoryValue.SubCategories or {}) > 0
				end),
			},
		},
	}))
end
