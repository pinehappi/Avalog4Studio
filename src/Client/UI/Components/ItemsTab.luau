local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local OnyxUITheme = require(Avalog.SourceCode.Client.UI.OnyxUITheme)
local States = require(Avalog.SourceCode.Client.UI.States)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.States.CatalogSearch)

local Children = Fusion.Children

local OnyxUIFolder = Avalog.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		CatalogSearch = CatalogSearch.Search,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local Items = Scope:Value({})

	local function LoadItems()
		local LoadedItems = {}

		for _ = 1, 20 do
			table.insert(LoadedItems, math.random(10000, 100000000))
		end

		Items:set(LoadedItems)
	end

	Scope:Observer(States.Catalog.Category):onChange(function()
		if Fusion.peek(Shown) then
			LoadItems()
		end
	end)
	Scope:Observer(States.Catalog.SubCategory):onChange(function()
		if Fusion.peek(Shown) then
			LoadItems()
		end
	end)
	LoadItems()

	local Search = Scope:CatalogSearch({ BundleTypes = { Enum.BundleType.BodyParts } })

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListWraps = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,
		Visible = Shown,

		[Children] = {
			Scope:ForValues(Search.Results, function(Use, Scope, Result)
				return OnyxUI.Themer.Theme:is(OnyxUITheme):during(function()
					return Scope:ItemButton {
						Data = Result,
					}
				end)
			end),
		},
	}))
end
