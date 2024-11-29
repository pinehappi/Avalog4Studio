local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)

local LocalAvatar = {
	Character = Instance.new("Model"),
	Humanoid = Instance.new("Humanoid"),
	HumanoidDescriber = HumanoidDescriber.new(Instance.new("HumanoidDescription")),
}

function LocalAvatar:SetCharacter(Character: Model)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		local HumanoidDescription = Humanoid:GetAppliedDescription()
		local HumanoidDescriberObject = HumanoidDescriber.new(HumanoidDescription)

		self.Character = Character
		self.Humanoid = Humanoid
		self.HumanoidDescriber = HumanoidDescriberObject
	end
end

Players.LocalPlayer.CharacterAdded:Connect(function(Character)
	LocalAvatar:SetCharacter(Character)
end)

local ExistingCharacter = Players.LocalPlayer.Character
if ExistingCharacter then
	LocalAvatar:SetCharacter(ExistingCharacter)
end

return LocalAvatar
