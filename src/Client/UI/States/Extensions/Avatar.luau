local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(script.Parent.Parent)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.Extensions.CatalogSearch)

local Avatar = {
	_Connections = {},
}

function Avatar:_UpdateEquippedBundles()
	local EquippedAssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
	local BundleIds = {}

	for _, AssetId in ipairs(EquippedAssetIdsValue) do
		local BundleId = CatalogSearch:GetBundleFromAsset(AssetId)
		if BundleId then
			table.insert(BundleIds, BundleId)
		end
	end

	States.Avatar.EquippedBundleIds:set(BundleIds)
end

function Avatar:_UpdateEquippedAssetIds()
	local AssetIdsValue = Fusion.peek(States.Avatar.AssetIds)
	local UnequippedAssetIds = {}

	for _, AssetId in ipairs(AssetIdsValue) do
		local CatalogInfo = CatalogSearch:GetProductInfo(AssetId, Enum.InfoType.Asset)
		if CatalogInfo and (CatalogInfo.AssetType == Enum.AvatarAssetType.EmoteAnimation) then
			if LocalAvatar.HumanoidDescriber:GetEquippedEmote(CatalogInfo.Name) == nil then
				table.insert(UnequippedAssetIds, AssetId)
			end
		end
	end

	for _, AssetId in ipairs(UnequippedAssetIds) do
		local Index = table.find(AssetIdsValue, AssetId)
		if Index ~= nil then
			table.remove(AssetIdsValue, Index)
		end
	end

	States.Avatar.EquippedAssetIds:set(AssetIdsValue)
end

function Avatar:_HandleAvatar()
	States.Avatar.Data:set(LocalAvatar.HumanoidDescriber:GetData())
	States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssets())
	self:_UpdateEquippedAssetIds()
	self:_UpdateEquippedBundles()
	States.Avatar.Character:set(LocalAvatar.Character)

	LocalAvatar.HumanoidDescriber.Updated:Connect(function(_, NewData)
		States.Avatar.Data:set(NewData)
		States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssets())
		self:_UpdateEquippedAssetIds()
		self:_UpdateEquippedBundles()
	end)
end

function Avatar:Stop()
	for _, Connection: RBXScriptConnection in ipairs(self._Connections) do
		Connection:Disconnect()
	end
end

table.insert(
	Avatar._Connections,
	LocalAvatar.Updated:Connect(function()
		Avatar:_HandleAvatar()
	end)
)

Avatar:_HandleAvatar()

return Avatar
