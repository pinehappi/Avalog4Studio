local Categories = require(script.Parent)

local function CategoriesToNames(CategoriesTable: { Categories.Category })
	local Names = {}

	for _, Category in ipairs(CategoriesTable) do
		table.insert(Names, Category.Name)
	end

	return Names
end

return CategoriesToNames
