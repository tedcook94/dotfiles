local wezterm = require('wezterm')

local config = wezterm.config_builder()

-- Specify shell path
config.default_prog = { '/usr/bin/zsh' }

-- Appearance settings
config.color_scheme = 'GitHub Dark'
config.font_size = 10
config.enable_tab_bar = false

return config
