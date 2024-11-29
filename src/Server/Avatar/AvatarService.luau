local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)

local RATE_LIMITS = {
	SetProperty = RateLimit(4, 1),
	SetAccessories = RateLimit(4, 1),
	SetEmotes = RateLimit(4, 1),
}

local AvatarService = {
	Name = script.Name,
	Client = {},
}

function AvatarService.Client:SetProperty(Player: Player, Name: string, Value: any)
	if not RATE_LIMITS.SetProperty(Player.UserId) then
		return
	end

	return AvatarService:SetProperty(Player, Name, Value)
end

function AvatarService.Client:SetAccessories(Player: Player, Accessories: { { any } })
	if not RATE_LIMITS.SetAccessories(Player.UserId) then
		return
	end

	return AvatarService:SetAccessories(Player, Accessories)
end

function AvatarService.Client:SetEmotes(Player: Player, Emotes: { { any } })
	if not RATE_LIMITS.SetEmotes(Player.UserId) then
		return
	end

	return AvatarService:SetEmotes(Player, Emotes)
end

function AvatarService:SetProperty(Player: Player, Name: string, Value: any)
	local HumanoidDescription = self:GetHumanoidDescription(Player)

	if HumanoidDescription then
		local _, ExistingValue = pcall(function()
			return HumanoidDescription[Name]
		end)

		if (ExistingValue ~= nil) and (Value ~= nil) then
			if typeof(ExistingValue) == typeof(Value) then
				if ExistingValue ~= Value then
					HumanoidDescription[Name] = Value

					return self:Apply(Player, HumanoidDescription):Await()
				end
			end
		end
	end

	return false
end

function AvatarService:SetAccessories(Player: Player, Accessories: { { any } })
	local HumanoidDescription = self:GetHumanoidDescription(Player)

	if HumanoidDescription then
		HumanoidDescription:SetAccessories(Accessories, true)

		return self:Apply(Player, HumanoidDescription):Await()
	end

	return false
end

function AvatarService:SetEmotes(Player: Player, Emotes: { { any } })
	local HumanoidDescription = self:GetHumanoidDescription(Player)

	if HumanoidDescription then
		HumanoidDescription:SetEquippedEmotes(Emotes)

		return self:Apply(Player, HumanoidDescription):Await()
	end

	return false
end

function AvatarService:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Future.Try(function()
				Humanoid:ApplyDescription(HumanoidDescription)
			end)
		end
	end

	return false
end

function AvatarService:GetHumanoidDescription(Player: Player): HumanoidDescription?
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Humanoid:GetAppliedDescription()
		end
	end

	return nil
end

function AvatarService:KnitStart() end

function AvatarService:KnitInit() end

return AvatarService
