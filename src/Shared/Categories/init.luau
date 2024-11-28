local AvatarAssetTypes = require(script.Parent.AvatarAssetTypes)

export type Category = {
	Name: string,
	SubCategories: { Category }?,
	AssetTypes: { Enum.AvatarAssetType }?,
	BundleTypes: { Enum.BundleType }?,
}

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
				{ Name = "Heads", AssetTypes = { Enum.AvatarAssetType.DynamicHead } },
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
				{ Name = "Bundles", BundleTypes = { Enum.BundleType.Animations } },
				{ Name = "Emotes", AssetTypes = AvatarAssetTypes.Types.Emotes },
			},
		},
	},
	Inventory = {},
	Build = { { Name = "Skin" }, { Name = "Build" } },
}

Categories.Inventory = Categories.Marketplace

return Categories
