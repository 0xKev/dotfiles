local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.front_end = "OpenGL"
config.max_fps = 120
config.animation_fps = 10

config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  "Noto Sans Devanagari",
  "Noto Sans CJK JP",
  "Noto Sans",
  "Noto Color Emoji",
  "Symbols Nerd Font",
})
config.font_size = 13.0
config.line_height = 1.23

config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 1
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 10000

config.use_dead_keys = false
config.debug_key_events = false

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.default_domain = "WSL:Ubuntu"
end

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1),
  })
end

return config