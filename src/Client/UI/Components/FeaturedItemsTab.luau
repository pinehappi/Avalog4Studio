local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogSearch)
local AvatarAssetTypes = require(Avalog.SourceCode.Shared.AvatarAssetTypes)

local ItemsTab = require(script.Parent.ItemsTab)

export type Props = ItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		ItemsTab = require(script.Parent.ItemsTab),
	})

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local FeaturedItems = Scope:Value({})
	local CatalogResults = Scope:Value({})
	local CatalogResultItems = Scope:ForValues(CatalogResults, function(Use, Scope, Result)
		return {
			Id = Result.Id,
			Type = Enum.AvatarItemType[Result.ItemType],
		}
	end)

	local function UpdateCatalogSearch()
		if not Fusion.peek(Shown) then
			return
		end

		local SearchObject = CatalogSearch.Search({
			BundleTypes = {
				Enum.BundleType.Animations,
				Enum.BundleType.BodyParts,
				Enum.BundleType.DynamicHead,
				Enum.BundleType.DynamicHeadAvatar,
				Enum.BundleType.Shoes,
			},
			AssetTypes = AvatarAssetTypes.Types.All,
		})

		SearchObject.Updated:Connect(function()
			CatalogResults:set(SearchObject.Results)
		end)

		CatalogResults:set(SearchObject.Results)
	end

	UpdateCatalogSearch()

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:Computed(function(Use)
			local FeaturedItemsValue = Use(FeaturedItems)
			local CatalogResultItemsValue = Use(CatalogResultItems)

			return {
				table.unpack(FeaturedItemsValue),
				table.unpack(CatalogResultItemsValue),
			}
		end),
	}))
end
