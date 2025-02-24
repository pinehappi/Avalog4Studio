local Sift = require(script.Parent.Parent.Sift)
local ThemeSpec = require(script.Parent.Parent[".pesde"]["imavafe_onyx-ui@0.5.3"]["onyx-ui"].Themer.ThemeSpec)
local Stator = require(script.Parent.Parent.Stator)
local DarkTheme = require(script.Parent.SourceCode.Client.UI.Themes.Dark)

export type Config = {
	Theme: ThemeSpec.ThemeSpec?,
}

local CONFIG_TEMPLATE: Config = {
	Theme = DarkTheme,
}

return Stator(Sift.Dictionary.copyDeep(CONFIG_TEMPLATE))
