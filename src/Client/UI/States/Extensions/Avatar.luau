local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(script.Parent.Parent)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogItems = require(Avalog.SourceCode.Client.UI.States.Extensions.CatalogItems)
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local DeepEquals = require(Avalog.SourceCode.Shared.Utils.DeepEquals)

local Avatar = {
	_Connections = {},
}

function Avatar:_LogHistoryEntry(NewData: HumanoidDescriber.Data)
	local HistoryDataValue = Fusion.peek(States.Avatar.DataHistory)

	local AlreadyExists = false
	for _, DataEntry in ipairs(HistoryDataValue) do
		if DeepEquals(DataEntry, NewData) then
			AlreadyExists = true
			break
		end
	end

	if AlreadyExists == false then
		table.insert(HistoryDataValue, NewData)
		States.Avatar.UndoHistory:set({})
	end

	States.Avatar.DataHistory:set(HistoryDataValue)
end

function Avatar:_UpdateEquippedBundles()
	local EquippedAssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
	local BundleIds = {}

	for _, AssetId in ipairs(EquippedAssetIdsValue) do
		local BundleId = CatalogItems:GetBundleIdFromAsset(AssetId)
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
		local CatalogInfo = CatalogItems:GetItem(AssetId, Enum.InfoType.Asset)
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
	States.Avatar.Loaded:set(false)

	local Data = LocalAvatar.HumanoidDescriber:GetData()

	local function Update(NewData)
		States.Avatar.Data:set(NewData)
		self:_LogHistoryEntry(NewData)

		States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssets())
		self:_UpdateEquippedAssetIds()
		self:_UpdateEquippedBundles()
	end

	States.Avatar.Character:set(LocalAvatar.Character)

	LocalAvatar.HumanoidDescriber.Updated:Connect(function(_, NewData)
		Update(NewData)
	end)
	Update(Data)

	States.Avatar.Loaded:set(true)
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

if Players:GetPlayerFromCharacter(LocalAvatar.Character) ~= nil then
	Avatar:_HandleAvatar()
end

return Avatar
