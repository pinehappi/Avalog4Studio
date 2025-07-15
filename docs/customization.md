---
sidebar_position: 2
---

# Customization

## Opening and closing

Make use of [`Avalog:ToggleOpen()`](/api/AvalogClient#ToggleOpen) and [`Avalog:SetOpen()`](/api/AvalogClient#SetOpen) as necessary.

## Featuring items

If you're a UGC creator, you may want to feature items within your homestore or game. Simply call the [`Avalog:Configure()`](/api/AvalogClient#Configure) method and pass in your items like so:

```lua
local Avalog = require(PATH_TO_AVALOG)

Avalog:Configure({
  Featured = {
    Items = {
      { -- An item entry
        Id = 14353423348, -- The item's AssetId
        ItemType = Enum.AvatarItemType.Asset, -- The item's type - Asset or Bundle
      },
    }
  }
})
```

To advertise items across Avalog, see [Sponsoring](/docs/sponsoring).

## Theming

Avalog supports a variety of UI theming properties, empowering you to match your world's unique mood and style.

```lua
Avalog:Configure({
  Theme = {
    -- Colors = {
    --   Primary = {
    --     Main = Color3.fromRGB(255, 255, 255),
    --   },

    --   Base = {
    --     Main = Color3.fromRGB(0, 0, 0),
    --   },
    --   BaseContent = {
    --     Main = Color3.fromRGB(255, 255, 255),
    --   },

    --   Neutral = {
    --     Main = Color3.fromRGB(51, 47, 46),
    --   },
    --   NeutralContent = {
    --     Main = Color3.fromRGB(196, 196, 195),
    --   },
    -- },
    -- Font = {
    --   Body = "rbxasset://fonts/families/Montserrat.json",
    --   Heading = "rbxasset://fonts/families/Montserrat.json",
    --   Monospace = "rbxasset://fonts/families/Montserrat.json",
    -- },
    -- FontWeight = {
    --   Body = Enum.FontWeight.SemiBold,
    --   Bold = Enum.FontWeight.Bold,
    --   Heading = Enum.FontWeight.Bold,
    -- },
    -- TextSize = {
    --   Base = 17,
    -- },
    -- CornerRadius = {
    --   Base = 6,
    -- },
    -- StrokeThickness = {
    --   Base = 1,
    -- },
    -- SpringSpeed = {
    --   Base = 60,
    -- },
    -- SpringDampening = {
    --   Base = 1.25,
    -- },
  }
})
```

See the full list of theme properties [here](https://github.com/loneka/onyx-ui/blob/main/src/Themer/ThemeSpec.luau).