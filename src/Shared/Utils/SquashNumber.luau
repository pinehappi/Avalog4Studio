local function SquashNumber(Value, Min, Max)
	local Difference = Max - Min
	return Min + (Value * Difference)
end

return SquashNumber
