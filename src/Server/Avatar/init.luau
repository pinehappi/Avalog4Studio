local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = script.Parent.Parent.Parent
local TableUtil = require(ReplicatedStorage.Avalog.Packages.TableUtil)
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local EnumSerDes = require(Avalog.Parent.EnumSerDes)
local PlayerDataStore = require(Avalog.SourceCode.Server.PlayerDataStorage.PlayerDataStore)

local RATE_LIMITS = {
	Update = RateLimit(1, 1),
	BulkPurchaseItems = RateLimit(1, 2),
}

local Avatar = {
	Avatars = {},
}

function Avatar:BulkPurchaseItems(Player: Player, Items: { any })
	return Future.Try(function()
		return MarketplaceService:PromptBulkPurchase(Player, Items, {})
	end):Await()
end

function Avatar:Update(Player: Player, Data: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = self:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

		HumanoidDescriberObject:UpdateData(function()
			return Data
		end)

		local PlayerDocument = PlayerDataStore:Get(Player)
		if PlayerDocument ~= nil then
			local DocumentData = TableUtil.Copy(PlayerDocument:read(), true)

			DocumentData.Avatar.Data = Data

			-- PlayerDocument:write(DocumentData)
		end

		self:Apply(Player, HumanoidDescription):Await()

		HumanoidDescriberObject:Destroy()
	end
end

function Avatar:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
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

function Avatar:GetCharacterObjects(Player: Player): (Model?, Humanoid?, HumanoidDescription?)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Character, Humanoid, Humanoid:FindFirstChildOfClass("HumanoidDescription")
		end
	end

	return nil
end

function Avatar:Start()
	Zap.BulkPurchaseAvatarItems.SetCallback(function(Player, Items)
		if not RATE_LIMITS.BulkPurchaseItems(Player.UserId) then
			return
		end

		local SafeItems: HumanoidDescriber.Data = EnumSerDes.DeserializeTree(Items)

		return Avatar:BulkPurchaseItems(Player, SafeItems)
	end)

	Zap.UpdateAvatar.SetCallback(function(Player, Data): ()
		if not RATE_LIMITS.Update(Player.UserId) then
			return
		end

		local SafeData: HumanoidDescriber.Data = EnumSerDes.DeserializeTree(Data)

		return Avatar:Update(Player, SafeData)
	end)

	PlayerDataStore.Loaded:Connect(function(Player, Document)
		local Data = Document:read()

		Avatar:Update(Player, Data.Avatar.Data)
	end)
end

return Avatar
