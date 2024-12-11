local RunService = game:GetService("RunService")
local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local LocalAvatar = require(Avalog.SourceCode.Client.Avatar.LocalAvatar)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local ViewportCamera = Scope:New "Camera" {
		CFrame = CFrame.lookAt(Vector3.new(0, 0, -8), Vector3.new(0, 0, 0)),
		CameraType = Enum.CameraType.Scriptable,
	}

	local CheckoutFailureShown = Scope:Value(false)

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
								Content = Scope:Computed(function(Use)
									local CheckoutFailureShownValue = Use(CheckoutFailureShown)
									if CheckoutFailureShownValue then
										return { "rbxassetid://13852128781", "Save" }
									else
										return { "rbxassetid://13846738861", "Save" }
									end
								end),
								SizeVariant = "Large",
								Disabled = States.Checkout.Loading,

								OnActivated = function()
									local Success = LocalAvatar:PromptCheckout()
									if not Success then
										CheckoutFailureShown:set(true)
										task.wait(1)
										CheckoutFailureShown:set(false)
									end
								end,
							},
							Scope:Button {
								Name = "DoneButton",
								Content = { "rbxassetid://13846852950", "Done" },
								Color = Theme.Colors.Success.Main,
								SizeVariant = "Large",

								OnActivated = function()
									if next(States.Services.AvatarService) ~= nil then
										States.Services.AvatarService:Update(Fusion.peek(States.Avatar.Data))
									end

									States.Open:set(false)
								end,
							},
						},
					},
					Scope:Frame {
						Name = "BottomControls",
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.fromScale(0.5, 1),
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						Scale = 1.25,

						[Children] = {
							Scope:IconButton {
								Image = "rbxassetid://13846120661",
								SizeVariant = "ExtraLarge",
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
							},
						},
					},
				},
			},
		},
	}))
end
