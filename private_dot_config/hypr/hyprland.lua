-- Hyprland config — Framework 13, single monitor, US keyboard
-- Syntax reference: https://wiki.hypr.land/Configuring/Start/

-- ========== VARIABLES ==========
local term     = "GTK_IM_MODULE=simple ghostty"      -- terminal (env: see ~/.config/uwsm/env)
local launcher = "omni-shell-ipc launcher toggle" -- quickshell launcher overlay
local browser  = "chromium"                       -- web browser
local mainMod  = "SUPER"     -- Framework "Windows" key

-- ========== INPUT ==========
hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "compose:caps", -- Caps Lock = compose key (Caps+' e -> é, Caps+" u -> ü)
        touchpad = {
            tap_to_click   = true, -- tap = click
            natural_scroll = true, -- mac-style scrolling
        },
    },
    misc = {
        force_default_wallpaper = 0,                 -- 0: no anime mascot wallpaper
        disable_hyprland_logo   = true,              -- no logo overlay
        background_color        = "rgba(eff1f5ff)", -- Catppuccin Latte base
        allow_session_lock_restore = true,           -- hyprlock crashed? re-running it from a TTY re-takes the lock
    },
    animations = {
        enabled = false, -- no slide/pop-in/fade: instant windows, workspaces, layers
    },
})

-- ========== BINDS ==========
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(term))        -- terminal
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(launcher))    -- launcher
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(launcher))    -- launcher, mac-style cmd+space
hl.bind(mainMod .. " + period",    hl.dsp.exec_cmd("rofimoji --selector fuzzel --typer wtype --clipboarder wl-copy --action type copy --skin-tone neutral --prompt emoji")) -- emoji picker, cmd+. style
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop")) -- clean uwsm session exit
hl.bind(mainMod .. " + Q",         hl.dsp.window.kill())          -- kill active window
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))     -- browser
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(term .. " -e btop")) -- system monitor
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(term .. " -e yazi")) -- file browser
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("omni-shell-ipc control toggle")) -- control center
hl.bind(mainMod .. " + comma",      hl.dsp.exec_cmd("omni-shell-ipc control clearNotifications")) -- clear toasts + history (bell right-click equivalent)
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("/home/cjmnuss/.local/bin/clipboard-pick")) -- clipboard history picker: fuzzel --dmenu over cliphist (omni-shell's IPC panel is corner-anchored + focusless)

-- Workspaces: SUPER + [1-9] switches, SUPER + SHIFT + [1-9] moves the window
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Focus with SUPER + arrows, move the window with SUPER + SHIFT + arrows
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Region screenshot to clipboard
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("/home/cjmnuss/.local/bin/screenshot region")) -- screenshot: file + clipboard + thumbnail toast (click toast = satty)
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("/home/cjmnuss/.local/bin/screenshot window")) -- focused-window screenshot

-- Screen brightness (laptop Fn keys): internal panel + external DDC monitor (brightness-step script)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("/home/cjmnuss/.local/bin/brightness-step up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("/home/cjmnuss/.local/bin/brightness-step down"), { locked = true, repeating = true })

-- Volume (laptop Fn keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })

-- ========== AUTOSTART ==========
-- hyprland.start fires once at session start; exec_cmd spawns async (exec-once style)
hl.on("hyprland.start", function()
    -- omni-shell: PATH prepends ~/.local/bin/omni-shim whose brightnessctl
    -- shim points the Control Center brightness slider at the ASUS (DDC).
    hl.exec_cmd("PATH=/home/cjmnuss/.local/bin/omni-shim:$PATH omni-shell")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("swaybg -i /home/cjmnuss/Pictures/waves-light.jpg -m fill") -- light wallpaper
    -- hypridle runs as a supervised systemd user service (hypridle.service, Restart=always) — a fire-and-forget autostart left it silently dead after the 2026-10-27 hyprlock crash cascade
    hl.exec_cmd("wl-paste --type text --watch /home/cjmnuss/.local/bin/cliphist-next store") -- clipboard history feed via master build (writes entry timestamps for cliphist-redact --min-age); text only
end)

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
do local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
