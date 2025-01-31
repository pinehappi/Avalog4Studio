local Avalog = script.Parent.Parent.Parent.Parent
local Bootloader = require(Avalog.Parent.Bootloader)

local function GetModules()
	local Modules = {}

	for _, Child in ipairs(script:GetChildren()) do
		if Child:IsA("ModuleScript") then
			Modules[Child.Name] = require(Child)
		end
	end

	return Modules
end

return Bootloader(GetModules())
