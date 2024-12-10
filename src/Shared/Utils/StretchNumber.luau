local function StretchNumber(Output, Min, Max)
	local Difference = Max - Min
	return (Output - Min) / Difference
end

return StretchNumber
