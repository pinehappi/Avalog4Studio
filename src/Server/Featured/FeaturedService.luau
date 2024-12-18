local HttpService = game:GetService("HttpService")

local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local Fetch = require(Avalog.Parent.Fetch)
local Signal = require(Avalog.Parent.Signal)
local GetEntriesFromArray = require(Avalog.SourceCode.Shared.Utils.GetEntriesFromArray)
local t = require(Avalog.Parent.t)

export type FeaturedListing = {
	TransactionHash: string,
	Bid: number,
	StartTime: number,
}
export type FeaturedItem = FeaturedListing & {
	Id: number,
	ItemType: Enum.AvatarItemType,
}
export type FeaturedCreator = FeaturedListing & {
	Id: number,
	CreatorType: Enum.CreatorType,
}
export type FeaturedData = {
	Items: { FeaturedItem },
	Creators: { FeaturedCreator },
}

local GITHUB_REPO = "UseAvalog/Featured"
local UPDATE_DELAY = 30 * 60
local FAILED_UPDATE_DELAY = 1 * 60

local FeaturedService = {
	Name = script.Name,
	Client = {},

	LastUpdated = nil,
	Data = {
		Items = {},
		Creators = {},
	},

	Updated = Signal.new(),
}

function FeaturedService.Client:GetCreators(Player: Player, Start: number, End: number): { FeaturedCreator }
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(Start), t.number(End)))

	return FeaturedService:GetCreators(Start, End)
end

function FeaturedService.Client:GetItems(Player: Player, Start: number, End: number): { FeaturedItem }
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(Start), t.number(End)))

	return FeaturedService:GetItems(Start, End)
end

function FeaturedService:GetCreators(Start: number, End: number): { FeaturedCreator }
	local Data = self:GetData()
	return GetEntriesFromArray(Data.Creators, Start, End)
end

function FeaturedService:GetItems(Start: number, End: number): { FeaturedItem }
	local Data = self:GetData()
	return GetEntriesFromArray(Data.Items, Start, End)
end

function FeaturedService:GetData(): FeaturedData
	if next(self.Data) ~= nil then
		return self.Data
	else
		return {
			Items = {},
			Creators = {},
		}
	end
end

function FeaturedService:SpawnUpdateLoop()
	return task.spawn(function()
		while true do
			local Success = self:Update()

			if Success then
				task.wait(UPDATE_DELAY)
			else
				task.wait(FAILED_UPDATE_DELAY)
			end
		end
	end)
end

function FeaturedService:Update()
	local Success, Result = self:_FetchLatestVersion():Await()

	if Success and (Result ~= nil) and (Result ~= self.LastUpdated) then
		local Success2, Result2 = self:_FetchLatestData():Await()

		if Success2 then
			self.Data = Result2
			self.LastUpdated = Result

			self.Updated:Fire(Result2)

			return true, Result2
		else
			warn(Result2)
		end
	end

	return false
end

function FeaturedService:_FetchLatestData()
	return Future.Try(function()
		local Success, Response =
			Fetch(`https://github.com/{GITHUB_REPO}/releases/latest/download/featured.json`):Await()

		if Success and Response.Ok then
			local Data = HttpService:JSONDecode(Response.Body)

			if typeof(Data) == "table" then
				return Data
			end
		end

		return {
			Items = {},
			Creators = {},
		}
	end)
end

function FeaturedService:_FetchLatestVersion()
	return Future.Try(function()
		local Success, Response = Fetch(`https://api.github.com/repos/{GITHUB_REPO}/releases/latest`):Await()

		if Success and Response.Ok then
			local Body = HttpService:JSONDecode(Response.Body)
			if Body then
				return Body["published_at"]
			end
		end

		return nil
	end)
end

function FeaturedService:_FetchIsActive()
	local Success, Response = Fetch(`https://api.github.com/repos/{GITHUB_REPO}/releases/latest`):Await()

	if Success then
		if Response.Status == 404 then
			return false
		end
	end

	return true
end

function FeaturedService:KnitStart()
	if self:_FetchIsActive() then
		self:SpawnUpdateLoop()
	end
end

function FeaturedService:KnitInit() end

return FeaturedService
