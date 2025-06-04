local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })

config.font_rules = {
  {
    italic = true,
    font = wezterm.font("JetBrains Mono", { weight = "Bold", italic = true }),
  },
}

config.color_scheme = "Catppuccin Mocha"
return config
