local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(script.Parent.Parent)
local Fusion = require(Avalog.Parent.Fusion)

local Scope = Fusion.scoped(Fusion)

local Avatar = {}

function Avatar:_HandleAvatar()
	print(LocalAvatar.Character)
	States.Avatar.Data:set(LocalAvatar.HumanoidDescriber:GetData())
	States.Avatar.Character:set(LocalAvatar.Character)

	LocalAvatar.HumanoidDescriber.Updated:Connect(function(_, NewData)
		States.Avatar.Data:set(NewData)
	end)
end

LocalAvatar.Updated:Connect(function()
	Avatar:_HandleAvatar()
end)

Avatar:_HandleAvatar()

return Avatar
