local PlayerDataStore = require(script.PlayerDataStore)

local PlayerDataStorage = {
	Store = PlayerDataStore,
}

function PlayerDataStorage:Start()
	PlayerDataStore:Start()
end

return PlayerDataStorage
