local MarketplaceService = game:GetService("MarketplaceService")
local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local EnumSerde = require(Avalog.SourceCode.Shared.Utils.EnumSerde)

local RATE_LIMITS = {
	Update = RateLimit(1, 1),
	BulkPurchaseItems = RateLimit(1, 2),
}

local AvatarService = {
	Avatars = {},
}

function AvatarService:BulkPurchaseItems(Player: Player, Items: { any })
	return Future.Try(function()
		return MarketplaceService:PromptBulkPurchase(Player, Items, {})
	end):Await()
end

function AvatarService:Update(Player: Player, Data: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = self:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

		HumanoidDescriberObject:UpdateData(function()
			return Data
		end)

		self:Apply(Player, HumanoidDescription):Await()

		HumanoidDescriberObject:Destroy()
	end
end

function AvatarService:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Future.Try(function()
				Humanoid:ApplyDescriptionReset(HumanoidDescription)
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

function AvatarService:Start()
	Zap.BulkPurchaseAvatarItems.SetCallback(function(Player, Items)
		if not RATE_LIMITS.BulkPurchaseItems(Player.UserId) then
			return
		end

		local SafeItems: HumanoidDescriber.Data = EnumSerde.DeserializeTree(Items)

		return AvatarService:BulkPurchaseItems(Player, SafeItems)
	end)

	Zap.UpdateAvatar.SetCallback(function(Player, Data): ()
		if not RATE_LIMITS.Update(Player.UserId) then
			return
		end

		local SafeData: HumanoidDescriber.Data = EnumSerde.DeserializeTree(Data)

		return AvatarService:Update(Player, SafeData)
	end)
end

return AvatarService
