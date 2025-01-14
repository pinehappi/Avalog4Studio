local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)
local Navigation = require(Avalog.SourceCode.Client.UI.States.Extensions.Navigation)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent[".pesde"]["imavafe_onyx-ui@0.5.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local ViewportCamera = Scope:New "Camera" {
		CFrame = CFrame.lookAt(Vector3.new(0, 0, -8), Vector3.new(0, 0, 0)),
		CameraType = Enum.CameraType.Scriptable,
	}

	return Scope:Image(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		MaxSize = Scope:Computed(function(Use)
			return Vector2.new(Use(Theme.Spacing["24"]), math.huge)
		end),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Base.Dark,
		Image = "rbxassetid://140363116814273",
		ScaleType = Enum.ScaleType.Crop,
		AutomaticSize = Enum.AutomaticSize.X,

		[Children] = {
			Scope:Frame {
				Name = "Contents",
				Size = UDim2.fromScale(1, 1),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),

				[Children] = {
					Scope:New "ViewportFrame" {
						Name = "Viewport",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						CurrentCamera = ViewportCamera,

						[Children] = {
							Scope:New "WorldModel" {
								[Children] = {
									ViewportCamera,

									Scope:Computed(function(Use)
										local CharacterValue = Use(States.Avatar.Character)

										if RunService:IsRunning() then
											return CharacterValue
										else
											return nil
										end
									end),
								},
							},
						},
					},
					Scope:Frame {
						Name = "TopControls",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:Button {
								Name = "SaveButton",
								Content = { "rbxassetid://13846738861", "Save" },
								SizeVariant = "Large",
								Disabled = States.Checkout.Loading,

								OnActivated = function()
									States.Checkout.Loading:set(true)
									local UnownedItems = LocalAvatar:GetUnownedItems()
									States.Checkout.Loading:set(false)

									if #UnownedItems > 0 then
										local Success = LocalAvatar:PromptCheckout(UnownedItems)
										if Success then
											MarketplaceService.PromptBulkPurchaseFinished:Once(function(_, Status)
												if Status == Enum.MarketplaceBulkPurchasePromptStatus.Completed then
													task.wait(0.5)
													LocalAvatar:SaveAvatar()
												end
											end)
										end
									else
										LocalAvatar:SaveAvatar()
									end
								end,
							},
							Scope:Button {
								Name = "DoneButton",
								Content = { "rbxassetid://13846852950", "Done" },
								Color = Theme.Colors.Success.Main,
								SizeVariant = "Large",

								OnActivated = function()
									LocalAvatar:UpdateServer(Fusion.peek(States.Avatar.Data))

									States.Open:set(false)
								end,
							},
						},
					},
					Scope:Card {
						Name = "BottomControls",
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.fromScale(0.5, 1),
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						Scale = 1.25,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:IconButton {
								Image = "rbxassetid://13846120661",
								SizeVariant = "ExtraLarge",
								Disabled = Scope:Computed(function(Use)
									local DataHistoryValue = Use(States.Avatar.DataHistory)
									local Category = Use(Navigation.Category)
									return (#DataHistoryValue <= 1) or (Category.Name == "Equipped")
								end),

								OnActivated = function()
									LocalAvatar:Undo()
								end,
							},
							Scope:IconButton {
								Image = "rbxassetid://13847364382",
								SizeVariant = "ExtraLarge",
								Color = Theme.Colors.Error.Main,

								OnActivated = function()
									LocalAvatar:Reset()
								end,
							},
							Scope:IconButton {
								Image = "rbxassetid://13846158505",
								SizeVariant = "ExtraLarge",
								Disabled = Scope:Computed(function(Use)
									local UndoHistoryValue = Use(States.Avatar.UndoHistory)
									local Category = Use(Navigation.Category)
									return (#UndoHistoryValue == 0) or (Category == "Equipped")
								end),

								OnActivated = function()
									LocalAvatar:Redo()
								end,
							},
						},
					},
				},
			},
		},
	}))
end
