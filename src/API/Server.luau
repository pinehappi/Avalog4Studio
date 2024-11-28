local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SERVER = SOURCE.Server

local Knit = require(PACKAGES.Knit)
local Loader = require(PACKAGES.Loader)

local AvalogServer = {
	Started = false,
}

function AvalogServer:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	Loader.LoadDescendants(SERVER, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Service$") ~= nil then
			return Knit.CreateService(require(Descendant))
		else
			return false
		end
	end)

	Knit.Start()
end

return AvalogServer
