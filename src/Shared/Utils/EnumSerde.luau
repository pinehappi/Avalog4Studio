export type SerEnumItem = {
	EnumType: string,
	Value: number,
}
export type SerEnumItemTree = {
	[any]: any | SerEnumItem | SerEnumItemTree,
}

local DeepCopy = require(script.Parent.DeepCopy)

local EnumSerde = {}

function EnumSerde.DeserializeTree(Tree)
	local NewTree = DeepCopy(Tree)

	for Key, Value in pairs(Tree) do
		if typeof(Value) == "table" then
			if (typeof(Value.EnumType) == "string") and (typeof(Value.Value) == "number") then
				local EnumItem = EnumSerde.Deserialize(Value)
				if EnumItem ~= nil then
					NewTree[Key] = EnumItem
				end
			else
				NewTree[Key] = EnumSerde.DeserializeTree(Value)
			end
		end
	end

	return NewTree
end

function EnumSerde.Deserialize(SerEnumItem: SerEnumItem): EnumItem?
	local EnumObject: Enum = Enum[SerEnumItem.EnumType]

	if EnumObject then
		local EnumItems: { EnumItem } = EnumObject:GetEnumItems()

		for _, EnumItem in pairs(EnumItems) do
			if EnumItem.Value == SerEnumItem.Value then
				return EnumItem
			end
		end
	end

	return nil
end

function EnumSerde.SerializeTree(Tree)
	local NewTree = DeepCopy(Tree)

	for Key, Value in pairs(Tree) do
		if typeof(Value) == "EnumItem" then
			NewTree[Key] = EnumSerde.Serialize(Value)
		elseif typeof(Value) == "table" then
			NewTree[Key] = EnumSerde.SerializeTree(Value)
		end
	end

	return NewTree
end

function EnumSerde.Serialize(EnumItem: EnumItem): SerEnumItem
	return {
		EnumType = tostring(EnumItem.EnumType),
		Value = EnumItem.Value,
	}
end

return EnumSerde
