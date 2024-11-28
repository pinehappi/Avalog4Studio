local MarketplaceService = game:GetService("MarketplaceService")
local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Future = require(Avalog.Parent.Future)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Button = require(OnyxUIFolder.Components.Button)

export type Props = Button.Props & {
	Data: Fusion.UsedAs<{ [string]: any }>,
	Equipped: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Data = OnyxUI.Util.Fallback(Props.Data, nil)
	local Equipped = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Equipped, false))

	print(Data)

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
							local DataValue = Use(Data)
							local ItemTypeToType = {
								Bundle = "BundleThumbnail",
							}
							local Type

							if DataValue and DataValue.ItemType then
								local FoundType = ItemTypeToType[DataValue.ItemType]
								if FoundType ~= nil then
									Type = FoundType
								else
									Type = "Asset"
								end
							end

							return `rbxthumb://id={DataValue.Id}&type={Type}&w=150&h=150`
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
									local DataValue = Use(Data)
									if DataValue and DataValue.Name then
										return DataValue.Name
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
									local DataValue = Use(Data)
									if DataValue and DataValue.Price then
										return { "rbxassetid://102562927562320", DataValue.Price }
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
