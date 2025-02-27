local Sift = require(script.Parent.Parent.Sift)
local ThemeSpec = require(script.Parent.Parent[".pesde"]["imavafe_onyx-ui@0.5.3"]["onyx-ui"].Themer.ThemeSpec)
local DarkTheme = require(script.Parent.SourceCode.Client.UI.Themes.Dark)

export type Item = {
	Id: number,
	ItemType: Enum.AvatarItemType,
}
export type Config = {
	Theme: ThemeSpec.ThemeSpec?,
	Featured: {
		Items: { Item }?,
	}?,
}

local CONFIG_TEMPLATE: Config = {
	Theme = DarkTheme,
	Featured = {
		Items = {},
	},
}

--[=[
	@class Config
]=]
--[=[
	@interface Config
	@within Config

	@field Theme Theme
]=]
--[=[
	@type Theme Theme
	@within Config

	The default dark theme can be [found here](https://github.com/UseAvalog/Avalog/blob/main/src/Client/UI/Themes/Dark.luau) for reference.
]=]
local Config = {
	Data = CONFIG_TEMPLATE,
}

function Config:Update(Data)
	Config.Data = Sift.Dictionary.merge(Config.Data, Data)
end

function Config:Get()
	return Sift.Dictionary.copyDeep(Config.Data)
end

return Config
