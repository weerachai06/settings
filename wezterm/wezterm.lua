local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font 'MesloLGLDZ Nerd Font Mono'
config.font_size = 14.0

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
-- config.hide_tab_bar_if_only_one_tab = true

return config
