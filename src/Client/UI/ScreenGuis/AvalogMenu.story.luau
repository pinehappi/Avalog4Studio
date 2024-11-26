local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local AvalogMenu = require(script.Parent.AvalogMenu)

return function(Parent: Instance)
	local Scope = Fusion.scoped(Fusion, {
		AvalogMenu = AvalogMenu,
	})

	Scope:AvalogMenu {
		Parent = Parent,
	}

	return function()
		Scope:doCleanup()
	end
end
