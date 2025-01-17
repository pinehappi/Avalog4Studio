local TableUtil = require(script.Parent.Parent.TableUtil)

export type Config = {}

local CONFIG_TEMPLATE: Config = {}

local Config = {
	Config = table.clone(CONFIG_TEMPLATE),
}

function Config:Update(ConfigModifier: Config)
	TableUtil.Reconcile(Config.Config, ConfigModifier)
end

return Config
