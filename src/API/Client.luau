local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SHARED = SOURCE.Shared
local CLIENT = SOURCE.Client
local DEFAULT_CONTROLLERS = {}

local Config = require(script.Parent.Config)
local Knit = require(PACKAGES.Knit)
local Loader = require(PACKAGES.Loader)
local FindFeatureFromModule = require(SHARED.FindFeatureFromModule)
local Prompts = require(SOURCE.Client.UI.States.Prompts)

local AvalogClient = {
	Started = false,
	Config = Config,
}

function AvalogClient:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	Loader.LoadDescendants(CLIENT, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Controller$") ~= nil then
			local Feature = FindFeatureFromModule(Descendant)

			if
				table.find(DEFAULT_CONTROLLERS, Descendant.Name)
				or (Feature and Config.Config.Systems[Feature].Enabled == true)
			then
				return Knit.CreateController(require(Descendant))
			else
				return false
			end
		else
			return false
		end
	end)

	Knit.Start()
end

function AvalogClient:Configure(Configuration: Config.Config)
	assert(not self.Started, "You cannot configure Avalog after starting it.")

	Config:Update(Configuration)
end

function AvalogClient:Prompt(Prompt)
	Prompts:PushPrompt(Prompt)
end

return AvalogClient
