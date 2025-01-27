local Avalog = script.Parent.Parent.Parent.Parent
local t = require(Avalog.Parent.t)

return t.strictInterface({
	Avatar = t.strictInterface({
		Data = t.table,
	}),
})
