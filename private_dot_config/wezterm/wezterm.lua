
local wezterm = require 'wezterm';
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  {
    key = 'm',
    mods = 'CMD',
    action = wezterm.action.DisableDefaultAssignment,
  }
}

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- config.font_size=14
-- config.line_height=1
config.hide_tab_bar_if_only_one_tab = true
-- config.color_scheme = "zenbones_light"
-- config.color_scheme = "BlulocoLight"
-- config.color_scheme = "Night Owlish Light"
-- config.color_scheme = "Google (light) (terminal.sexy)"
-- config.color_scheme = 'Solarized (light) (terminal.sexy)'
config.color_scheme = 'Catppuccin Latte'

config.audible_bell = "Disabled"

return config
