local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",     -- Main monospace font
  "Noto Sans Devanagari",        -- For Devanagari
  "Noto Sans CJK JP",            -- For Japanese
  "Noto Sans",                   -- For Latin/Cyrillic
  "Noto Color Emoji",            -- For full emoji support
  "Symbols Nerd Font",           -- For box drawing, arrows, etc
})

config.allow_square_glyphs_to_overflow_width = "Never"

config.window_background_opacity = 1
config.window_decorations = "RESIZE"

config.color_scheme = "Catppuccin Mocha"

-- Needed
config.use_dead_keys = false

-- logging keypress
config.debug_key_events = false

config.set_environment_variables = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Use OSC 7 as per the above example
  config.set_environment_variables['prompt'] =
    '$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m '
  -- use a more ls-like output format for dir
  config.set_environment_variables['DIRCMD'] = '/d'
  -- And inject clink into the command prompt
  -- I'm already using the auto injection via clink so no need to set here
end


-- Leader key and useful bindings (like tmux)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 5000 }
local act = wezterm.action

config.keys = config.keys or {}
-- Optional: Tab index shortcuts
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

return config
