local wezterm = require 'wezterm';
return {
  font = wezterm.font_with_fallback({ "Comic Code Ligatures", }),
  line_height=1.1,
  hide_tab_bar_if_only_one_tab = true,
  -- color_scheme = "seoulbones_light",
  color_scheme = "zenwritten_light",
  -- color_scheme = "Night Owlish Light",
  -- color_scheme = "Github_custom",
  audible_bell = "Disabled",
}
