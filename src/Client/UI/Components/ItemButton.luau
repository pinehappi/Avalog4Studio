local MarketplaceService = game:GetService("MarketplaceService")
local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Future = require(Avalog.Parent.Future)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Button = require(OnyxUIFolder.Components.Button)

export type Props = Button.Props & {
	AssetId: Fusion.UsedAs<number>,
	Equipped: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local AssetId = OnyxUI.Util.Fallback(Props.AssetId, nil)
	local Equipped = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Equipped, false))

	local ProductInfo = Scope:Value(nil)

	local function UpdateProductInfo()
		task.spawn(function()
			local AssetIdValue = Fusion.peek(AssetId)

			if AssetIdValue == nil then
				return
			end

			Future.Try(function()
				return MarketplaceService:GetProductInfo(AssetIdValue)
			end):After(function(Success, Result)
				if Success then
					ProductInfo:set(Result)
				end
			end)
		end)
	end
	Scope:Observer(function()
		UpdateProductInfo()
	end)
	UpdateProductInfo()

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		StrokeEnabled = Equipped,
		StrokeThickness = Theme.StrokeThickness["2"],
		StrokeColor = Theme.Colors.BaseContent.Main,
		ListEnabled = false,

		OnActivated = function()
			Equipped:set(not Fusion.peek(Equipped))
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
							local AssetIdValue = Use(AssetId)
							return `rbxthumb://id={AssetIdValue}&type=Asset&w=150&h=150`
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
									local ProductInfoValue = Use(ProductInfo)
									if ProductInfoValue and ProductInfoValue.Name then
										return ProductInfoValue.Name
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
									local ProductInfoValue = Use(ProductInfo)
									if ProductInfoValue and ProductInfoValue.PriceInRobux then
										return { "rbxassetid://102562927562320", ProductInfoValue.PriceInRobux }
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
				Checked = Equipped,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
			},
		},
	}))
end
