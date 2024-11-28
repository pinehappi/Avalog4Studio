local MD5 = require(script.Parent.MD5)

local function ConcatDictionary(Dictionary: { [any]: any }): string
	local Result = ""

	for Key, Value in pairs(Dictionary) do
		local Additive = ""

		if typeof(Value) == "table" then
			Additive = ConcatDictionary(Value)
		else
			Additive = tostring(Key) .. "=" .. tostring(Value) .. "&"
		end

		Result = Result .. Additive
	end

	return Result:sub(1, -2)
end

local function HashDictionary(Dictionary: { [any]: any })
	return MD5.sumhexa(ConcatDictionary(Dictionary))
end

return HashDictionary
