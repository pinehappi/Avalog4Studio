local Avalog = script.Parent.Parent.Parent.Parent.Parent.Parent
local Knit = require(Avalog.Parent.Knit)
local States = require(script.Parent.Parent)

type KnitService = typeof(Knit.GetService)

local Services = { "AvatarService" }

function Services:Start()
	Knit.OnStart():andThen(function()
		for ServiceName, _ in pairs(States.Services) do
			States.Services[ServiceName] = Knit.GetService(ServiceName)
		end
	end)
end

return Services
