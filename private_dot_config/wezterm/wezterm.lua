local wezterm = require 'wezterm';
return {
  font = wezterm.font_with_fallback{
    { family = "Iosevka Term"},
    "Symbols NF",
  },
  font_size=16,
  line_height=1.2,
  hide_tab_bar_if_only_one_tab = true,
  -- color_scheme = "Builtin Solarized Light",
  -- color_scheme = "zenbones_light",
  color_scheme = "BlulocoLight",
  -- color_scheme = "Night Owlish Light",
  -- color_scheme = "Github_custom",
  audible_bell = "Disabled",
}
