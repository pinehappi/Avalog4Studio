local AssetService = game:GetService("AssetService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

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
	OwnedAssets = {},
	BundleDetails = {},
}

function CatalogSearch:GetBundleDetails(BundleId: number)
	if self.BundleDetails[BundleId] == nil then
		local Success, Result = Future.Try(function()
			return AssetService:GetBundleDetailsAsync(BundleId)
		end):Await()

		if Success then
			self.BundleDetails[BundleId] = Result
		end
	end

	return self.BundleDetails[BundleId]
end

function CatalogSearch:OwnsAsset(AssetId: number)
	if table.find(self.OwnedAssets, AssetId) == nil then
		local Success, Result = Future.Try(function()
			return MarketplaceService:PlayerOwnsAsset(Players.LocalPlayer, AssetId)
		end):Await()
		if Success and Result then
			table.insert(self.OwnedAssets, AssetId)
		end
	end

	return table.find(self.OwnedAssets, AssetId) ~= nil
end

function CatalogSearch:GetProductInfo(Id: number, InfoType: Enum.InfoType): { [string]: any }?
	local INFO_TYPE_TABLES = {
		[Enum.InfoType.Asset] = self.KnownAssets,
		[Enum.InfoType.Bundle] = self.KnownBundles,
	}
	local INFO_TYPE_AVATAR_ITEM_TYPES = {
		[Enum.InfoType.Asset] = Enum.AvatarItemType.Asset,
		[Enum.InfoType.Bundle] = Enum.AvatarItemType.Bundle,
	}
	local RelevantTable = INFO_TYPE_TABLES[InfoType]
	local AvatarItemType = INFO_TYPE_AVATAR_ITEM_TYPES[InfoType]

	if RelevantTable and AvatarItemType then
		local KnownEntry = RelevantTable[Id]
		if KnownEntry then
			return KnownEntry
		else
			local Success, Result = Future.Try(function()
				return MarketplaceService:GetProductInfo(Id, InfoType)
			end):Await()
			if Success then
				local Item = {
					Id = Result.Id,
					Name = Result.Name,
					Price = Result.PriceInRobux,
					Type = AvatarItemType,
					Offsale = not Result.IsForSale,
				}

				RelevantTable[Id] = Item
				return Item
			else
				return nil
			end
		end
	end

	return nil
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
					Offsale = Entry.IsOffSale,
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
