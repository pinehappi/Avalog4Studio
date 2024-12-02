local Avalog = script.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(Avalog.SourceCode.Client.UI.States)
local Fusion = require(Avalog.Parent.Fusion)

local Scope = Fusion.scoped(Fusion)

local Avatar = {}

function Avatar:_HandleAvatar()
	local HumanoidDescriber = LocalAvatar.HumanoidDescriber

	States.Avatar.Data:set(HumanoidDescriber:GetData())

	HumanoidDescriber.Updated:Connect(function(_, NewData)
		States.Avatar.Data:set(NewData)
	end)
end

function Avatar:Start()
	LocalAvatar.Updated:Connect(function()
		self:_HandleAvatar()
	end)

	self:_HandleAvatar()
end

return Avatar
