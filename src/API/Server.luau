local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SERVER = SOURCE.Server

local Bootloader = require(PACKAGES.Bootloader)

local function GetModules()
	local Modules = {}

	for _, Child in ipairs(SERVER:GetChildren()) do
		if Child:IsA("ModuleScript") then
			table.insert(Modules, Child)
		end
	end

	return Modules
end

local AvalogServer = {
	Bootloader = Bootloader(GetModules()),
	Started = false,
}

function AvalogServer:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	AvalogServer.Bootloader:Initialize()
	AvalogServer.Bootloader:Start()
end

return AvalogServer
