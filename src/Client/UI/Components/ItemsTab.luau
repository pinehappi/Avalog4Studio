local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)
local States = require(Avalog.SourceCode.Client.UI.States)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.CatalogSearch)
local Navigation = require(Avalog.SourceCode.Client.UI.States.Navigation)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		CatalogSearch = CatalogSearch.Search,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local DeepestCategory = Scope:Computed(function(Use)
		local CategoryValue = Use(Navigation.Category)
		local SubCategoryValue = Use(Navigation.SubCategory)

		if SubCategoryValue ~= nil then
			return SubCategoryValue
		else
			return CategoryValue
		end
	end)
	local BundleTypes = Scope:Computed(function(Use)
		local DeepestCategoryValue = Use(DeepestCategory)

		if DeepestCategoryValue and DeepestCategoryValue.BundleTypes then
			return DeepestCategoryValue.BundleTypes
		else
			return {}
		end
	end)
	local AssetTypes = Scope:Computed(function(Use)
		local DeepestCategoryValue = Use(DeepestCategory)

		if DeepestCategoryValue and DeepestCategoryValue.AssetTypes then
			return DeepestCategoryValue.AssetTypes
		else
			return {}
		end
	end)

	local Search = Scope:Value(nil)
	local Results = Scope:Computed(function(Use)
		local SearchValue = Use(Search)

		if SearchValue then
			return Use(SearchValue.Results)
		else
			return {}
		end
	end)

	local function UpdateSearch()
		local BundleTypesValue = Fusion.peek(BundleTypes)
		local AssetTypesValue = Fusion.peek(AssetTypes)

		Search:set(Scope:CatalogSearch({ BundleTypes = BundleTypesValue, AssetTypes = AssetTypesValue }))
	end
	Scope:Observer(BundleTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(AssetTypes):onChange(function()
		UpdateSearch()
	end)

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListWraps = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,
		Visible = Shown,

		[Children] = {
			Scope:ForValues(Results, function(Use, Scope, Result)
				return OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
					return Scope:ItemButton {
						Data = Result,
					}
				end)
			end),
		},
	}))
end
