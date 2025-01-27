local PlayerDataStore = require(script.Parent.PlayerDataStore)

local Service = {}

function Service:Start()
	PlayerDataStore:Start()
end

return Service
