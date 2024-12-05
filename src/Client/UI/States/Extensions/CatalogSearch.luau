local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local HashDictionary = require(Avalog.SourceCode.Shared.Utils.HashDictionary)
local Signal = require(Avalog.Parent.Signal)

export type SearchParams = {
	SearchKeyword: string?,
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
	KnownAssets = {},
	KnownBundles = {},
}

function CatalogSearch:GetBundleInfo(BundleId: number): { [string]: any }?
	local KnownBundle = self.KnownBundles[BundleId]

	if KnownBundle then
		return KnownBundle
	else
		local Success, Result = Future.Try(function()
			return MarketplaceService:GetProductInfo(BundleId, Enum.InfoType.Bundle)
		end):Await()
		if Success then
			local Item = {
				BundleId = Result.Id,
				Name = Result.Name,
				Price = Result.Price,
				Type = Enum.AvatarItemType.Bundle,
			}

			self.KnownBundles[BundleId] = Item
			return Item
		else
			return nil
		end
	end
end

function CatalogSearch:GetAssetInfo(AssetId: number): { [string]: any }?
	local KnownAsset = self.KnownAssets[AssetId]

	if KnownAsset then
		return KnownAsset
	else
		local Success, Result = Future.Try(function()
			return MarketplaceService:GetProductInfo(AssetId, Enum.InfoType.Asset)
		end):Await()
		if Success then
			local AssetType
			for _, AvatarAssetType in ipairs(Enum.AvatarAssetType:GetEnumItems()) do
				if AvatarAssetType.Value == Result.AssetTypeId then
					AssetType = AvatarAssetType
				end
			end

			local Item = {
				Id = Result.AssetId,
				Name = Result.Name,
				Price = Result.PriceInRobux,
				Type = Enum.AvatarItemType.Asset,
				AssetType = AssetType,
			}

			self.KnownAssets[AssetId] = Item
			return Item
		else
			return nil
		end
	end
end

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
			assert(self.Pages ~= nil, "Pages does not exist.")

			self.Pages:AdvanceToNextPageAsync()
			return self.Pages:GetCurrentPage()
		end):After(function(Success, Result)
			if Success and Result then
				self:_LoadPage(Result)
			end
		end)
	end

	function Search:_LoadPage(Page: { [number]: any })
		for _, Entry in ipairs(Page) do
			local Tables = {
				Asset = CatalogSearch.KnownAssets,
				Bundle = CatalogSearch.KnownBundles,
			}
			local AppropriateTable = Tables[Entry.ItemType]

			if AppropriateTable then
				AppropriateTable[Entry.Id] = {
					Id = Entry.Id,
					Name = Entry.Name,
					Price = Entry.Price,
					Type = Enum.AvatarItemType[Entry.ItemType],
					AssetType = (Entry.AssetType and Enum.AvatarAssetType[Entry.AssetType]) or nil,
				}
			end

			table.insert(self.Results, Entry)
		end

		self.Updated:Fire()
	end

	function Search:Destroy()
		self.Results = {}
		self.Updated:Destroy()

		if self.Pages ~= nil then
			self.Pages:Destroy()
		end
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

function CatalogSearch:Stop()
	for Hash, Search in pairs(self.Searches) do
		Search:Destroy()
		self.Searches[Hash] = nil
	end
end

return CatalogSearch
