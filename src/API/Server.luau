local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SERVER = SOURCE.Server

local Loader = require(PACKAGES.Loader)

local AvalogServer = {
	Started = false,
}

function AvalogServer:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	Loader.LoadDescendants(SERVER, function(Descendant)
		return Descendant:IsA("ModuleScript") and Descendant.Name:match("Service$") ~= nil
	end)
end

return AvalogServer
