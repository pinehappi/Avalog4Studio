local AvatarEditorService = game:GetService("AvatarEditorService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local HashDictionary = require(Avalog.SourceCode.Shared.Utils.HashDictionary)
local Signal = require(Avalog.Parent.Signal)

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

function CatalogSearch.Search(Params: SearchParams)
	local ParamsHash = HashDictionary(Params)
	if CatalogSearch.Searches[ParamsHash] ~= nil then
		return CatalogSearch.Searches[ParamsHash]
	end

	local Search = {
		Results = {},
		Pages = nil,
		Updated = Signal.new(),
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
		for _, Entry in ipairs(Page) do
			table.insert(Search.Results, Entry)
		end

		self.Updated:Fire()
	end

	CatalogSearch.Pages(Params):After(function(Success, Result)
		if Success then
			Search.Pages = Result
			Search:_LoadPage(Result:GetCurrentPage())
		end
	end)

	CatalogSearch.Searches[ParamsHash] = Search

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
