local Avalog = require(script.Parent.Parent.Avalog)
local Config = require(script.Parent.Config)

Avalog.Config:Update(Config)

Avalog:Start()
