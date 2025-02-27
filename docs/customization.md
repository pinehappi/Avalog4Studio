---
sidebar_position: 2
---

# Customization

## Opening and Closing

Make use of [`Avalog:ToggleOpen()`](/api/AvalogClient#ToggleOpen) and [`Avalog:SetOpen()`](/api/AvalogClient#SetOpen) as necessary.

## Featuring Items

Call the [`Avalog:Configure()`](/api/AvalogClient#Configure) method and pass in a `Featured.Items` array like so:

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

## Theming

Call the [`Avalog:Configure()`](/api/AvalogClient#Configure) method and pass in a theme property like so:

```lua
local Avalog = require(PATH_TO_AVALOG)

Avalog:Configure({
  Theme = {
    Colors = {
      Primary = {
        Main = Util.Colors.Violet["500"],
      },
      Secondary = {
        Main = Util.Colors.White,
      },
      Accent = {
        Main = Util.Colors.White,
      },

      Neutral = {
        Main = Util.Colors.Stone["800"],
      },
      NeutralContent = {
        Main = Util.Colors.Stone["300"],
      },

      Base = {
        Main = Util.Colors.Stone["900"],
      },
      BaseContent = {
        Main = Util.Colors.White,
      },

      Success = {
        Main = Util.Colors.Green["500"],
      },
      Error = {
        Main = Util.Colors.Red["500"],
      },
      Warning = {
        Main = Util.Colors.Amber["500"],
      },
      Info = {
        Main = Util.Colors.Cyan["400"],
      },
    },
    Font = {
      Body = "rbxasset://fonts/families/Montserrat.json",
      Heading = "rbxasset://fonts/families/Montserrat.json",
      Monospace = "rbxasset://fonts/families/Montserrat.json",
    },
    FontWeight = {
      Body = Enum.FontWeight.SemiBold,
      Bold = Enum.FontWeight.Bold,
      Heading = Enum.FontWeight.Bold,
    },
    TextSize = {
      Base = 19,
    },
    CornerRadius = {
      Base = 6,
    },
    StrokeThickness = {
      Base = 2,
    },
    Spacing = {
      Base = 16,
    },
    SpringSpeed = {
      Base = 50,
    },
    SpringDampening = {
      Base = 1,
    },
    Sound = {},
    Emphasis = {},
  }
})
```

Color properties shown here make use of OnyxUI's `Util.Color` utility, but can be any `Color3` value.