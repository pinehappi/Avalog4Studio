local Avalog = script.Parent.Parent.Parent.Parent
local PlayerDataStore = require(Avalog.SourceCode.Storage.Utils.PlayerDataStore)
local DataValidater = require(script.Parent.DataValidater)
local DataTemplate = require(script.Parent.DataTemplate)

local DataStore = PlayerDataStore("PlayerData", {
	defaultData = DataTemplate,
	validate = DataValidater,
})

return DataStore
