local Avalog = script.Parent.Parent.Parent.Parent.Parent
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local States = require(Avalog.SourceCode.Client.UI.States)
local Fusion = require(Avalog.Parent.Fusion)
local PropertyValueBinds = require(Avalog.SourceCode.Client.Avatar.PropertyValueBinds)

local Scope = Fusion.scoped(Fusion)

local Avatar = {}

function Avatar:_HandleAvatar()
	local HumanoidDescriber = LocalAvatar.HumanoidDescriber
	local HumanoidDescription = HumanoidDescriber.HumanoidDescription

	self:_BindProperties()

	HumanoidDescriber.AccessoriesChanged:Connect(function()
		self:_UpdateAccessories()
	end)
	self:_UpdateAccessories()

	HumanoidDescription.EmotesChanged:Connect(function()
		self:_UpdateEmotes()
	end)
	self:_UpdateEmotes()
end

function Avatar:_BindProperties()
	local HumanoidDescription = LocalAvatar.HumanoidDescriber.HumanoidDescription

	for Property, Value in pairs(PropertyValueBinds.Binds.All) do
		local function UpdateValue()
			Value:set(HumanoidDescription[Property])
		end

		HumanoidDescription:GetPropertyChangedSignal(Property):Connect(function()
			UpdateValue()
		end)

		Scope:Observer(Value):onChange(function()
			local ValueValue = Fusion.peek(Value)

			if HumanoidDescription[Property] ~= ValueValue then
				if next(States.Services.AvatarService) ~= nil then
					States.Services.AvatarService:SetProperties({ [Property] = ValueValue })
				end
			end
		end)

		UpdateValue()
	end
end

function Avatar:_UpdateAccessories()
	local Accessories = LocalAvatar.HumanoidDescriber.HumanoidDescription:GetAccessories(true)

	States.Avatar.Accessories:set(Accessories)

	if next(States.Services.AvatarService) ~= nil then
		States.Services.AvatarService:SetAccessories(Accessories)
	end
end

function Avatar:_UpdateEmotes()
	States.Avatar.Emotes:set(LocalAvatar.HumanoidDescriber.HumanoidDescription:GetEquippedEmotes())
end

function Avatar:Start()
	LocalAvatar.Updated:Connect(function()
		self:_HandleAvatar()
	end)

	self:_HandleAvatar()
end

return Avatar
