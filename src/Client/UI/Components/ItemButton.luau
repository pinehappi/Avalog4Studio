local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Button = require(OnyxUIFolder.Components.Button)

export type Props = Button.Props & {
	Equipped: Fusion.UsedAs<boolean>?,
	Name: Fusion.UsedAs<string>?,
	Price: Fusion.UsedAs<number>?,
	AssetId: Fusion.UsedAs<number>?,
	Type: Fusion.UsedAs<Enum.AvatarAssetType>?,
	AssetType: Fusion.UsedAs<Enum.AvatarAssetType>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Name = OnyxUI.Util.Fallback(Props.Name, "Name")
	local Price = OnyxUI.Util.Fallback(Props.Price, nil)
	local AssetId = OnyxUI.Util.Fallback(Props.AssetId, nil)
	local Type = OnyxUI.Util.Fallback(Props.Type, nil)
	local AssetType = OnyxUI.Util.Fallback(Props.AssetType, nil)

	local Equippable = Scope:Computed(function(Use)
		local TypeValue = Use(Type)

		return TypeValue == Enum.AvatarItemType.Asset
	end)
	local Equipped = Scope:Computed(function(Use)
		local AssetIdsValue = Use(States.Avatar.AssetIds)
		local AssetIdValue = Use(AssetId)

		return table.find(AssetIdsValue, AssetIdValue) ~= nil
	end)
	local EquippedValueState = Scope:Value(Fusion.peek(Equipped))

	Scope:Observer(Equipped):onChange(function()
		EquippedValueState:set(Fusion.peek(Equipped))
	end)

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		StrokeEnabled = Equipped,
		StrokeThickness = Theme.StrokeThickness["2"],
		StrokeColor = Theme.Colors.BaseContent.Main,
		ListEnabled = false,

		OnActivated = function()
			local TypeValue = Fusion.peek(Type)
			local AssetTypeValue = Fusion.peek(AssetType)
			local AssetIdValue = Fusion.peek(AssetId)
			local NameValue = Fusion.peek(Name)

			LocalAvatar:ToggleCatalogItem({
				AssetId = AssetIdValue,
				Name = NameValue,
				Type = TypeValue,
				AssetType = AssetTypeValue,
			})
		end,

		[Children] = {
			Scope:Frame {
				Name = "Details",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Vertical,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				Size = UDim2.fromScale(1, 0),

				[Children] = {
					Scope:Image {
						BackgroundTransparency = 1,
						Image = Scope:Computed(function(Use)
							local ItemTypeToType = {
								[Enum.AvatarItemType.Bundle] = "BundleThumbnail",
								[Enum.AvatarItemType.Asset] = "Asset",
							}
							local TypeValue = Use(Type)
							local AssetIdValue = Use(AssetId)

							return `rbxthumb://id={AssetIdValue}&type={(ItemTypeToType[TypeValue] or "Asset")}&w=150&h=150`
						end),
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["1"]))
						end),
						Size = Scope:Computed(function(Use)
							local Offset = Use(Theme.Spacing["8"])
							return UDim2.fromOffset(Offset, Offset)
						end),
					},
					Scope:Frame {
						Name = "Text",
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Vertical,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:Text {
								Text = Scope:Computed(function(Use)
									local NameValue = Use(Name)

									if NameValue then
										return NameValue
									else
										return "Item"
									end
								end),
								Size = Scope:Computed(function(Use)
									return UDim2.fromOffset(0, Use(Theme.TextSize["1"]) * 2)
								end),
								AutomaticSize = Enum.AutomaticSize.X,
								ClipsDescendants = true,
								RichText = false,
							},
							Scope:IconText {
								Name = "Price",
								Content = Scope:Computed(function(Use)
									local PriceValue = Use(Price)

									if PriceValue then
										return { "rbxassetid://102562927562320", PriceValue }
									else
										return { "rbxassetid://102562927562320", 0 }
									end
								end),
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.25"]))
								end),
								ListWraps = false,
								ContentWrapped = false,
							},
						},
					},
				},
			},
			Scope:Checkbox {
				Name = "EquippedMarker",
				Checked = EquippedValueState,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Active = false,
				Visible = Equippable,
			},
		},
	}))
end
