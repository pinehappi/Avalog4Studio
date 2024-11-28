local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local CLIENT = SOURCE.Client

local Knit = require(PACKAGES.Knit)
local Loader = require(PACKAGES.Loader)

local AvalogClient = {
	Started = false,
}

function AvalogClient:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	Loader.LoadDescendants(CLIENT, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Controller$") ~= nil then
			return Knit.CreateController(require(Descendant))
		else
			return false
		end
	end)

	Knit.Start()
end

return AvalogClient
