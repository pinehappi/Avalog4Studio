local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local Lapis = require(Avalog.Parent.Lapis)

local function NewPlayerDataStore(Name: string, Options: Lapis.CollectionOptions<{}>)
	local PlayerDataStore = {
		Collection = Lapis.createCollection(Name, Options),
		Documents = {},
	}

	function PlayerDataStore:Load(Player: Player)
		PlayerDataStore.Collection
			:load(`{Player.UserId}`, { Player.UserId })
			:andThen(function(Document)
				if Player.Parent == nil then
					Document:close():catch(warn)
					return
				end

				PlayerDataStore.Documents[Player] = Document
			end)
			:catch(function()
				warn(`Player {Player}'s data failed to load.`)
				Player:Kick("Data failed to load. Please rejoin.")
			end)
	end

	function PlayerDataStore:Unload(Player: Player)
		local Document = PlayerDataStore:Get(Player)

		if Document ~= nil then
			PlayerDataStore.Documents[Player] = nil
			Document:close():catch(warn)
		end
	end

	function PlayerDataStore:Get(Player: Player)
		return PlayerDataStore.Documents[Player]
	end

	function PlayerDataStore:Start()
		for _, Player in ipairs(Players:GetPlayers()) do
			PlayerDataStore:Load(Player)
		end

		Players.PlayerAdded:Connect(function(Player)
			PlayerDataStore:Load(Player)
		end)

		Players.PlayerRemoving:Connect(function(Player)
			PlayerDataStore:Unload(Player)
		end)
	end

	return PlayerDataStore
end

return NewPlayerDataStore
