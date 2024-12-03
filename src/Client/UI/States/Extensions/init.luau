local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Loader = require(Avalog.Parent.Loader)

local Extensions = {}

function Extensions:Start()
	Loader.SpawnAll(Loader.LoadChildren(script), "Start")
end

function Extensions:Initialize()
	Loader.LoadChildren(script)
end

return Extensions
