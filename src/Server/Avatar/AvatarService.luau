local Players = game:GetService("Players")
local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local ReconcileTable = require(Avalog.SourceCode.Shared.Utils.ReconcileTable)

local RATE_LIMITS = {
	Reconcile = RateLimit(4, 1),
	Update = RateLimit(4, 1),
	SetOutfit = RateLimit(1, 1),
}

local AvatarService = {
	Name = script.Name,
	Client = {},
}

function AvatarService.Client:Update(Player: Player, Data: HumanoidDescriber.Data)
	if not RATE_LIMITS.Update(Player.UserId) then
		return
	end

	return AvatarService:Update(Player, Data)
end

function AvatarService.Client:SetOutfit(Player: Player, OutfitId: number)
	if not RATE_LIMITS.SetOutfit(Player.UserId) then
		return
	end

	return AvatarService:SetOutfit(Player, OutfitId)
end

function AvatarService.Client:Reconcile(Player: Player, SupplementaryData: HumanoidDescriber.Data)
	if not RATE_LIMITS.Reconcile(Player.UserId) then
		return
	end

	return AvatarService:Reconcile(Player, SupplementaryData)
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

function AvatarService:Update(Player: Player, Data: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = self:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber.new(HumanoidDescription)

		HumanoidDescriberObject:UpdateData(function()
			return Data
		end)

		Humanoid:ApplyDescriptionReset(HumanoidDescription)
	end
end

function AvatarService:Reconcile(Player: Player, SupplementaryData: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = self:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber.new(HumanoidDescription)

		HumanoidDescriberObject:UpdateData(function(Data)
			ReconcileTable(Data, SupplementaryData)
			return Data
		end)

		Humanoid:ApplyDescription(HumanoidDescription)
	end
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
			return Character, Humanoid, Humanoid:FindFirstChildOfClass("HumanoidDescription")
		end
	end

	return nil
end

function AvatarService:KnitStart() end

function AvatarService:KnitInit() end

return AvatarService
