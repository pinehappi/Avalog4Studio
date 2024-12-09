local ASSET_TYPES = Enum.AvatarAssetType:GetEnumItems()

local function AssetTypeFromId(Id: number): Enum.AvatarAssetType?
	for _, AssetType in ipairs(ASSET_TYPES) do
		if AssetType.Value == Id then
			return AssetType
		end
	end

	return nil
end

return AssetTypeFromId
