export type Category = {
	Name: string,
	SubCategories: { Category }?,
}

local function Category(Name: string, SubCategories: { Category }?)
	local CategoryObject = {
		Name = Name,
		SubCategories = SubCategories,
	}

	return CategoryObject
end

local Categories: { [string]: { Category } } = {
	Marketplace = {
		Category("All"),
		Category("Characters"),
		Category("Head & Body", {
			Category("Heads"),
			Category("Hair"),
		}),
		Category("Clothing", {
			Category("Shirts"),
			Category("T-Shirts"),
			Category("Sweaters"),
			Category("Jackets"),
			Category("Pants"),
			Category("Dresses & Skirts"),
			Category("Shorts"),
			Category("Shoes"),
			Category("Classic Shirts"),
			Category("Classic T-Shirts"),
			Category("Classic Pants"),
		}),
		Category("Accessories", {
			Category("Head"),
			Category("Face"),
			Category("Neck"),
			Category("Shoulder"),
			Category("Front"),
			Category("Back"),
			Category("Waist"),
		}),
		Category("Animation", {
			Category("Bundles"),
			Category("Emotes"),
		}),
	},
	Inventory = {},
	Build = {
		Category("Skin"),
		Category("Build"),
	},
}

Categories.Inventory = Categories.Marketplace

return Categories
