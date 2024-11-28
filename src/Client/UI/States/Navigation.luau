local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local Fusion = require(Avalog.Parent.Fusion)

local MODES = { "Marketplace", "Inventory", "Build" }

local CategoryStates = {}

local Scope = Fusion.scoped(Fusion)

CategoryStates.Mode = Scope:Computed(function(Use)
	return MODES[Use(States.Catalog.Mode)]
end)
CategoryStates.Category = Scope:Computed(function(Use)
	local ActiveModeValue = Use(CategoryStates.Mode)
	local CategoryValue = Use(States.Catalog.Category)

	return Categories[ActiveModeValue][CategoryValue]
end)
CategoryStates.SubCategory = Scope:Computed(function(Use)
	local CategoryValue = Use(CategoryStates.Category)
	local SubCategoryValue = Use(States.Catalog.SubCategory)

	if CategoryValue and CategoryValue.SubCategories then
		return CategoryValue.SubCategories[SubCategoryValue]
	else
		return nil
	end
end)

return CategoryStates
