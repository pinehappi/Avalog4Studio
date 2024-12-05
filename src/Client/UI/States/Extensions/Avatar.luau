local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(script.Parent.Parent)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.Extensions.CatalogSearch)

local Avatar = {
	_Connections = {},
}

function Avatar:_UpdateEquippedAssetIds()
	local AssetIdsValue = Fusion.peek(States.Avatar.AssetIds)

	for Index, AssetId in ipairs(AssetIdsValue) do
		local CatalogInfo = CatalogSearch:GetAssetInfo(AssetId)
		if CatalogInfo and (CatalogInfo.AssetType == Enum.AvatarAssetType.EmoteAnimation) then
			if LocalAvatar.HumanoidDescriber:GetEquippedEmote(CatalogInfo.Name) == nil then
				table.remove(AssetIdsValue, Index)
			end
		end
	end

	States.Avatar.EquippedAssetIds:set(AssetIdsValue)
end

function Avatar:_HandleAvatar()
	States.Avatar.Data:set(LocalAvatar.HumanoidDescriber:GetData())
	States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssetIds())
	self:_UpdateEquippedAssetIds()
	States.Avatar.Character:set(LocalAvatar.Character)

	LocalAvatar.HumanoidDescriber.Updated:Connect(function(_, NewData)
		States.Avatar.Data:set(NewData)
		States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssetIds())
		self:_UpdateEquippedAssetIds()
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
