local Players = game:GetService("Players")
local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)

local RATE_LIMITS = {
	SetProperty = RateLimit(4, 1),
	SetAccessories = RateLimit(4, 1),
	SetEmotes = RateLimit(4, 1),
	SetOutfit = RateLimit(1, 1),
}

local AvatarService = {
	Name = script.Name,
	Client = {},
}

function AvatarService.Client:SetOutfit(Player: Player, OutfitId: number)
	if not RATE_LIMITS.SetOutfit(Player.UserId) then
		return
	end

	return AvatarService:SetOutfit(Player, OutfitId)
end

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

function AvatarService:SetOutfit(Player: Player, OutfitId: number)
	local _, Humanoid, _ = self:GetCharacterObjects(Player)

	if Humanoid then
		local Success, Result = Future.Try(function()
			return Players:GetHumanoidDescriptionFromOutfitId(OutfitId)
		end):Await()

		if Success then
			Result.Parent = workspace
			Humanoid:ApplyDescription(Result)
		end
	end
end

function AvatarService:SetProperty(Player: Player, Name: string, Value: any)
	local _, _, HumanoidDescription = self:GetCharacterObjects(Player)
	local HumanoidDescriberObject = HumanoidDescriber.new(HumanoidDescription)

	return HumanoidDescriberObject:SetProperties({ [Name] = Value })
end

function AvatarService:SetAccessories(Player: Player, Accessories: { { any } })
	local _, _, HumanoidDescription = self:GetCharacterObjects(Player)

	if HumanoidDescription then
		HumanoidDescription:SetAccessories(Accessories, true)

		return self:Apply(Player, HumanoidDescription):Await()
	end

	return false
end

function AvatarService:SetEmotes(Player: Player, Emotes: { { any } })
	local _, _, HumanoidDescription = self:GetCharacterObjects(Player)

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

function AvatarService:GetCharacterObjects(Player: Player): (Model?, Humanoid?, HumanoidDescription?)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Character, Humanoid, Humanoid:GetAppliedDescription()
		end
	end

	return nil
end

function AvatarService:KnitStart() end

function AvatarService:KnitInit() end

return AvatarService
