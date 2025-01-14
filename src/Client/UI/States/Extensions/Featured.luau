local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent.Parent)
local Fusion = require(Avalog.Parent.Fusion)

local FeaturedService

local Featured = {}

function Featured:FetchCreators(Count: number?)
	if Count == nil then
		Count = 1
	end

	if FeaturedService then
		local StartIndex = #Fusion.peek(States.Featured.Creators)

		local Success, Result = FeaturedService:GetCreators(StartIndex, StartIndex + Count)

		if Success and Result then
			self:_AddEntries(Result, States.Featured.Creators)

			return true
		end
	end

	return false
end

function Featured:FetchItems(Count: number?)
	if Count == nil then
		Count = 1
	end

	if FeaturedService then
		local StartIndex = #Fusion.peek(States.Featured.Items)

		local Success, Result = FeaturedService:GetItems(StartIndex, StartIndex + Count)

		if Success and Result then
			self:_AddEntries(Result, States.Featured.Items)

			return true
		end
	end

	return false
end

function Featured:_AddEntries(Entries, EntriesState: Fusion.Value<Fusion.Scope<any>, any>)
	local EntriesValue = Fusion.peek(EntriesState)

	for _, Entry in ipairs(Entries) do
		if self:_FindInValues(Entries, EntriesValue) ~= nil then
			table.insert(EntriesValue, Entry)
		end
	end

	EntriesState:set(EntriesValue)
end

function Featured:_FindInValues(Values: {}, Callback: (any) -> boolean?)
	local FoundEntries = {}

	for _, Entry in pairs(Values) do
		if Callback(Entry) then
			table.insert(FoundEntries, Entry)
		end
	end

	return FoundEntries
end

function Featured:Start()
	self:FetchItems(100)
end

return Featured
