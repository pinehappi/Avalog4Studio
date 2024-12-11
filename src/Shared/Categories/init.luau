local AvatarAssetTypes = require(script.Parent.AvatarAssetTypes)
local DeepCopy = require(script.Parent.Utils.DeepCopy)

export type Category = {
	Name: string,
	SubCategories: { Category }?,
	AssetTypes: { Enum.AvatarAssetType }?,
	BundleTypes: { Enum.BundleType }?,
}

local function PurgeBundleCategories(CategoriesToPurge: { Category })
	local TrashIndexes = {}

	for Index, Category in pairs(CategoriesToPurge) do
		Category.BundleTypes = nil

		if Category.SubCategories then
			PurgeBundleCategories(Category.SubCategories)

			if #Category.SubCategories == 0 then
				table.insert(TrashIndexes, Index)
			end
		else
			if not Category.AssetTypes then
				table.insert(TrashIndexes, Index)
			end
		end
	end

	for _, Index in ipairs(TrashIndexes) do
		table.remove(CategoriesToPurge, Index)
	end
end

local Categories: { [string]: { Category } } = {
	Marketplace = {
		{
			Name = "All",
			AssetTypes = AvatarAssetTypes.Types.All,
			BundleTypes = {
				Enum.BundleType.Animations,
				Enum.BundleType.BodyParts,
				Enum.BundleType.DynamicHead,
				Enum.BundleType.DynamicHeadAvatar,
				Enum.BundleType.Shoes,
			},
		},
		{
			Name = "Characters",
			BundleTypes = {
				Enum.BundleType.BodyParts,
			},
		},
		{
			Name = "Head & Body",
			SubCategories = {
				{
					Name = "Heads",
					BundleTypes = { Enum.BundleType.DynamicHead },
					AssetTypes = { Enum.AvatarAssetType.DynamicHead, Enum.AvatarAssetType.Head },
				},
				{ Name = "Hair", AssetTypes = { Enum.AvatarAssetType.HairAccessory } },
			},
		},
		{
			Name = "Clothing",
			SubCategories = {
				{ Name = "Shirts", AssetTypes = { Enum.AvatarAssetType.ShirtAccessory } },
				{ Name = "T-Shirts", AssetTypes = { Enum.AvatarAssetType.TShirtAccessory } },
				{ Name = "Sweaters", AssetTypes = { Enum.AvatarAssetType.SweaterAccessory } },
				{ Name = "Jackets", AssetTypes = { Enum.AvatarAssetType.JacketAccessory } },
				{ Name = "Pants", AssetTypes = { Enum.AvatarAssetType.PantsAccessory } },
				{ Name = "Dresses & Skirts", AssetTypes = { Enum.AvatarAssetType.DressSkirtAccessory } },
				{ Name = "Shorts", AssetTypes = { Enum.AvatarAssetType.ShortsAccessory } },
				{
					Name = "Shoes",
					AssetTypes = { Enum.AvatarAssetType.LeftShoeAccessory, Enum.AvatarAssetType.RightShoeAccessory },
				},
				{ Name = "Classic Shirts", AssetTypes = { Enum.AvatarAssetType.Shirt } },
				{ Name = "Classic T-Shirts", AssetTypes = { Enum.AvatarAssetType.TShirt } },
				{ Name = "Classic Pants", AssetTypes = { Enum.AvatarAssetType.Pants } },
			},
		},
		{
			Name = "Accessories",
			SubCategories = {
				{ Name = "Head", AssetTypes = { Enum.AvatarAssetType.Hat } },
				{ Name = "Face", AssetTypes = { Enum.AvatarAssetType.FaceAccessory } },
				{ Name = "Neck", AssetTypes = { Enum.AvatarAssetType.NeckAccessory } },
				{ Name = "Shoulder", AssetTypes = { Enum.AvatarAssetType.ShoulderAccessory } },
				{ Name = "Front", AssetTypes = { Enum.AvatarAssetType.FrontAccessory } },
				{ Name = "Back", AssetTypes = { Enum.AvatarAssetType.BackAccessory } },
				{ Name = "Waist", AssetTypes = { Enum.AvatarAssetType.WaistAccessory } },
			},
		},
		{
			Name = "Animation",
			SubCategories = {
				{
					Name = "Bundles",
					BundleTypes = { Enum.BundleType.Animations },
					AssetTypes = AvatarAssetTypes.Types.Animations,
				},
				{ Name = "Emotes", AssetTypes = AvatarAssetTypes.Types.Emotes },
			},
		},
	},
	Inventory = {},
	Customize = { { Name = "Equipped" }, { Name = "Skin" }, { Name = "Build" } },
}

Categories.Inventory = DeepCopy(Categories.Marketplace)

PurgeBundleCategories(Categories.Inventory)

return Categories
