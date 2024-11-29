local AvatarService = {
	Name = script.Name,
	Client = {},
}

function AvatarService.Client:SetProperty(Player: Player, Name: string, Value: any)
	return AvatarService:SetProperty(Player, Name, Value)
end

function AvatarService.Client:SetAccessories(Player: Player, Accessories: { { any } })
	return AvatarService:SetAccessories(Player, Accessories)
end

function AvatarService.Client:SetEmotes(Player: Player, Emotes: { { any } })
	return AvatarService:SetEmotes(Player, Emotes)
end

function AvatarService:SetProperty(Player: Player, Name: string, Value: any)
	local HumanoidDescription = self:GetHumanoidDescription(Player)

	if HumanoidDescription then
		local ExistingValue = HumanoidDescription[Name]
		if (ExistingValue ~= nil) and (Value ~= nil) then
			if typeof(ExistingValue) == typeof(Value) then
				if ExistingValue ~= Value then
					HumanoidDescription[Name] = Value
				end
			end
		end
	end

	self:Apply(Player, HumanoidDescription)
end

function AvatarService:SetAccessories(Player: Player, Accessories: { { any } })
	local HumanoidDescription = self:GetHumanoidDescription(Player)
	if HumanoidDescription then
		HumanoidDescription:SetAccessories(Accessories, true)
		self:Apply(Player, HumanoidDescription)
	end
end

function AvatarService:SetEmotes(Player: Player, Emotes: { { any } })
	local HumanoidDescription = self:GetHumanoidDescription(Player)
	if HumanoidDescription then
		HumanoidDescription:SetEquippedEmotes(Emotes)
		self:Apply(Player, HumanoidDescription)
	end
end

function AvatarService:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
	local Character = Player.Character
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid:ApplyDescription(HumanoidDescription)
		end
	end
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
