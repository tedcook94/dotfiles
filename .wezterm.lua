local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Specify shell path
config.default_prog = { "/usr/bin/zsh" }

-- Appearance settings
config.color_scheme = "nord"
config.font_size = 10
config.enable_tab_bar = false

-- Fix some keybindings
config.enable_kitty_keyboard = true

return config
