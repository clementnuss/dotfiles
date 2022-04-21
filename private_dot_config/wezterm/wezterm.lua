local wezterm = require 'wezterm';
return {
  font = wezterm.font_with_fallback({ "Fira Code", }),
  line_height=1.1,
  hide_tab_bar_if_only_one_tab = true,
  color_scheme = "Tomorrow",
}
