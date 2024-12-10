local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.Extensions.CatalogSearch)
local Navigation = require(Avalog.SourceCode.Client.UI.States.Extensions.Navigation)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children
local Out = Fusion.Out
local OnChange = Fusion.OnChange

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.1"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
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
	local SearchQuery = Scope:Computed(function(Use)
		local SearchQueryValue = Use(States.Catalog.SearchQuery)
		local SearchingValue = Use(States.Catalog.Searching)

		return (SearchingValue and SearchQueryValue) or nil
	end)

	local Search = Scope:Value(nil)
	local Results = Scope:Value({})

	local function UpdateSearch()
		if not Fusion.peek(Shown) then
			return
		end

		local BundleTypesValue = Fusion.peek(BundleTypes)
		local AssetTypesValue = Fusion.peek(AssetTypes)
		local SearchQueryValue = Fusion.peek(SearchQuery)

		local SearchObject = CatalogSearch.Search({
			BundleTypes = BundleTypesValue,
			AssetTypes = AssetTypesValue,
			SearchKeyword = SearchQueryValue,
		})

		SearchObject.Updated:Connect(function()
			Results:set(SearchObject.Results)
		end)

		Search:set(SearchObject)
		Results:set(SearchObject.Results)
	end
	Scope:Observer(BundleTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(AssetTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(SearchQuery):onChange(function()
		UpdateSearch()
	end)
	UpdateSearch()

	local AbsoluteCanvasSize = Scope:Value(Vector2.new())
	local AbsoluteWindowSize = Scope:Value(Vector2.new())

	local CatalogItemsTab = Scope:Hydrate(Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
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
		CanvasSize = UDim2.fromOffset(0, 0),

		[Children] = {
			Scope:ForValues(Results, function(Use, Scope, Result)
				return OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
					return Scope:ItemButton {
						Id = Result.Id,
						Type = Enum.AvatarItemType[Result.ItemType],
					}
				end)
			end),
		},
	}))) {
		[OnChange "CanvasPosition"] = function(CanvasPosition)
			local CanvasHeight = Fusion.peek(AbsoluteCanvasSize).Y - Fusion.peek(AbsoluteWindowSize).Y

			if CanvasPosition.Y >= CanvasHeight then
				local SearchValue = Fusion.peek(Search)
				if (SearchValue ~= nil) and not SearchValue.IsFinished then
					SearchValue:LoadNextPage()
				end
			end
		end,
		[Out "AbsoluteCanvasSize"] = AbsoluteCanvasSize,
		[Out "AbsoluteWindowSize"] = AbsoluteWindowSize,
	}

	Scope:Observer(Search):onChange(function()
		CatalogItemsTab.CanvasPosition = Vector2.new()
	end)

	return CatalogItemsTab
end
