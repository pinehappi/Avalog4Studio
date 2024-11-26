local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<typeof(Fusion)>, Props: Props)
	local Scope = Fusion.innerScope(Scope, OnyxUI.Util, OnyxUI.Components)

	return Scope:New "ScreenGui" {
		Name = script.Name,
		Parent = Props.Parent,

		[Children] = {},
	}
end
