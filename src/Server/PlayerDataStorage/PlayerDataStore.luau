local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Avalog = script.Parent.Parent.Parent.Parent
local Skilift = require(ReplicatedStorage.Avalog.Packages.Skilift)
local Squash = require(ReplicatedStorage.Avalog.Packages.Squash)
local DataValidater = require(script.Parent.DataValidater)
local DataTemplate = require(script.Parent.DataTemplate)
local NewPlayerDataStore = require(Avalog.SourceCode.Storage.Utils.PlayerDataStore)
local AvatarDataSerDes = require(script.Parent.SerDes.AvatarData)

local PlayerDataStore = NewPlayerDataStore {
	name = "AvalogPlayerData",
	migrations = {},
	default_data = function()
		return DataTemplate
	end,
	schema = DataValidater,
}

local Actions = {
	SetAvatarData = function(OldData, AvatarData)
		local Cursor = Squash.cursor()
		AvatarDataSerDes.ser(Cursor, AvatarData)

		OldData.Avatar.Data = Squash.tobuffer(Cursor)

		return OldData
	end,
}

Skilift.action.normal(Actions.SetAvatarData)

PlayerDataStore.Actions = Actions

return PlayerDataStore
