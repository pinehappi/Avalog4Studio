local Sift = require(script.Parent.Parent.Sift)
local ThemeSpec = require(script.Parent.Parent[".pesde"]["imavafe_onyx-ui@0.5.3"]["onyx-ui"].Themer.ThemeSpec)
local DarkTheme = require(script.Parent.SourceCode.Client.UI.Themes.Dark)

export type Config = {
	Theme: ThemeSpec.ThemeSpec?,
}

local CONFIG_TEMPLATE: Config = {
	Theme = DarkTheme,
}

local Config = {
	Data = CONFIG_TEMPLATE,
}

function Config:Update(Data)
	return Sift.Dictionary.merge(Config.Data, Data)
end

function Config:Get()
	return Sift.Dictionary.copyDeep(Config.Data)
end

return Config
