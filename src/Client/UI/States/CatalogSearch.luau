local AvatarEditorService = game:GetService("AvatarEditorService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local Fusion = require(Avalog.Parent.Fusion)

export type SearchParams = {
	String: string?,
	MinPrice: number?,
	MaxPrice: number?,
	SortType: Enum.CatalogSortType?,
	SortAggregation: Enum.CatalogSortAggregation?,
	CategoryFilter: Enum.CatalogCategoryFilter?,
	SalesTypeFilter: Enum.SalesTypeFilter?,
	BundleTypes: { Enum.BundleType }?,
	AssetTypes: { Enum.AvatarAssetType }?,
	IncludeOffSale: boolean?,
	CreatorName: string?,
	Limit: number?,
}

local CatalogSearch = {
	Searches = {},
}

function CatalogSearch.Search(Scope: Fusion.Scope<typeof(Fusion)>, Params: SearchParams)
	local Search = {
		Results = Scope:Value({}),
		Pages = nil,
	}

	function Search:LoadNextPage()
		return Future.Try(function()
			assert(Search.Pages ~= nil, "Pages does not exist.")

			Search.Pages:AdvanceToNextPageAsync()
			return Search.Pages:GetCurrentPage()
		end):After(function(Success, Result)
			if Success and Result then
				self:_LoadPage(Result)
			end
		end)
	end

	function Search:_LoadPage(Page: { [number]: any })
		local ResultsValue = Fusion.peek(Search.Results)

		for _, Entry in ipairs(Page) do
			table.insert(ResultsValue, Entry)
		end

		Search.Results:set(ResultsValue)
	end

	CatalogSearch.Pages(Params):After(function(Success, Result)
		if Success then
			Search.Pages = Result
			Search:_LoadPage(Result:GetCurrentPage())
		end
	end)

	return Search
end

function CatalogSearch.Pages(Params: SearchParams)
	local CatalogSearchParams = CatalogSearch.Params(Params)

	return Future.Try(function()
		return AvatarEditorService:SearchCatalog(CatalogSearchParams)
	end)
end

function CatalogSearch.Params(Params: SearchParams)
	local CatalogSearchParams = CatalogSearchParams.new()

	for Key, Value in pairs(Params) do
		CatalogSearchParams[Key] = Value
	end

	return CatalogSearchParams
end

return CatalogSearch
