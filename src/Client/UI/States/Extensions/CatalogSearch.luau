local AssetService = game:GetService("AssetService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local HashDictionary = require(Avalog.SourceCode.Shared.Utils.HashDictionary)
local Signal = require(Avalog.Parent.Signal)
local AssetTypeFromId = require(Avalog.SourceCode.Shared.Utils.AssetTypeFromId)

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
export type CatalogItem = {
	Id: number,
	Name: string,
	Type: Enum.AvatarItemType,
	AssetType: Enum.AvatarAssetType?,
	Price: number,
	Offsale: boolean,
}

local CatalogSearch = {
	Searches = {},
	KnownAssets = {},
	KnownBundles = {},
	OwnedAssets = {},
	OwnedBundles = {},
	BundleDetails = {},
	BundleAssets = {},
}

function CatalogSearch:GetBundleFromAsset(AssetId: number)
	for BundleId, AssetIds in pairs(self.BundleAssets) do
		if table.find(AssetIds, AssetId) ~= nil then
			return BundleId
		end
	end

	return nil
end

function CatalogSearch:GetBundleDetails(BundleId: number)
	if self.BundleDetails[BundleId] == nil then
		local Success, Result = Future.Try(function()
			return AssetService:GetBundleDetailsAsync(BundleId)
		end):Await()

		if Success then
			self.BundleAssets[BundleId] = {}
			for _, Item in ipairs(Result.Items) do
				if Item.Type == "Asset" then
					table.insert(self.BundleAssets[BundleId], Item.Id)
				end
			end

			self.BundleDetails[BundleId] = Result
		end
	end

	return self.BundleDetails[BundleId]
end

function CatalogSearch:OwnsItem(Id: number, Type: Enum.AvatarItemType)
	local ItemTypeTables = {
		[Enum.AvatarItemType.Asset] = self.OwnedAssets,
		[Enum.AvatarItemType.Bundle] = self.OwnedBundles,
	}
	local RelevantTable = ItemTypeTables[Type]

	if RelevantTable then
		if table.find(RelevantTable, Id) == nil then
			local Success, Result = Future.Try(function()
				if Type == Enum.AvatarItemType.Asset then
					return MarketplaceService:PlayerOwnsAsset(Players.LocalPlayer, Id)
				elseif Type == Enum.AvatarItemType.Bundle then
					return MarketplaceService:PlayerOwnsBundle(Players.LocalPlayer, Id)
				else
					return nil
				end
			end):Await()
			if Success and Result then
				table.insert(RelevantTable, Id)
			end
		end

		return table.find(RelevantTable, Id) ~= nil
	end

	return false
end

function CatalogSearch:GetProductInfo(Id: number, InfoType: Enum.InfoType): CatalogItem?
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
					Id = Result.AssetId,
					Name = Result.Name,
					Price = Result.PriceInRobux,
					Type = AvatarItemType,
					AssetType = AssetTypeFromId(Result.AssetTypeId),
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
				local Item: CatalogItem = {
					Id = Entry.Id,
					Name = Entry.Name,
					Price = Entry.Price,
					Offsale = Entry.IsOffSale,
					Type = Enum.AvatarItemType[Entry.ItemType],
					AssetType = (Entry.AssetType and Enum.AvatarAssetType[Entry.AssetType]) or nil,
				}

				AppropriateTable[Entry.Id] = Item
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
