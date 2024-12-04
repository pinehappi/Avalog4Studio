local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Loader = require(Avalog.Parent.Loader)

local Extensions = {}

function Extensions:Stop()
	Loader.SpawnAll(Loader.LoadChildren(script), "Stop")
end

function Extensions:Start()
	Loader.SpawnAll(Loader.LoadChildren(script), "Start")
end

function Extensions:Initialize()
	Loader.LoadChildren(script)
end

return Extensions
