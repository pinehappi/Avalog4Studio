local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(script.Parent.Parent)

local Avatar = {
	_Connections = {},
}

function Avatar:_HandleAvatar()
	States.Avatar.Data:set(LocalAvatar.HumanoidDescriber:GetData())
	States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssetIds())
	States.Avatar.Character:set(LocalAvatar.Character)

	LocalAvatar.HumanoidDescriber.Updated:Connect(function(_, NewData)
		States.Avatar.Data:set(NewData)
		States.Avatar.AssetIds:set(LocalAvatar.HumanoidDescriber:GetAssetIds())
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
