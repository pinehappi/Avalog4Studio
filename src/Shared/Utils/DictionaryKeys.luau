local function DictionaryKeys(Dictionary: { [any]: any })
	local Keys = {}

	for Key, _ in pairs(Dictionary) do
		table.insert(Keys, Key)
	end

	return Keys
end

return DictionaryKeys
