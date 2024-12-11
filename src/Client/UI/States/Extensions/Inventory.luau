local AvatarEditorService = game:GetService("AvatarEditorService")

local States = require(script.Parent.Parent)

local Inventory = {}

function Inventory:Start()
	AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(Result)
		if Result == Enum.AvatarPromptResult.Success then
			States.Inventory.AccessAllowed:set(true)
		else
			States.Inventory.AccessAllowed:set(false)
		end
	end)
end

return Inventory
