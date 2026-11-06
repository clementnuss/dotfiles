-- https://wiki.hypr.land/Configuring/Start/

local term     = "GTK_IM_MODULE=simple ghostty" -- until a re-login confirms uwsm/env exports it
local launcher = "omni-shell-ipc launcher toggle"
local browser  = "chromium"
local bin      = "/home/cjmnuss/.local/bin/"
local mainMod  = "SUPER"

hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "compose:caps",
        touchpad = {
            tap_to_click   = true,
            natural_scroll = true,
        },
    },
    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        background_color           = "rgba(eff1f5ff)",
        allow_session_lock_restore = true, -- lets a crashed hyprlock be re-run from a TTY
        focus_on_activate          = true, -- xdg-open'd files focus the already-open app
    },
    animations = {
        enabled = false,
    },
})

hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + period",    hl.dsp.exec_cmd("rofimoji --selector fuzzel --typer wtype --clipboarder wl-copy --action type copy --skin-tone neutral --prompt emoji"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + Q",         hl.dsp.window.kill())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(term .. " -e btop"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(term .. " -e yazi"))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("omni-shell-ipc control toggle"))
hl.bind(mainMod .. " + comma",     hl.dsp.exec_cmd("omni-shell-ipc control clearNotifications"))
hl.bind(mainMod .. " + CTRL + V",  hl.dsp.exec_cmd(bin .. "clipboard-pick"))
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd(bin .. "screenshot region"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(bin .. "screenshot window"))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(bin .. "brightness-step up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(bin .. "brightness-step down"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })

-- hypridle, udiskie, kanata, drata-agent and seadrive are systemd user units
hl.on("hyprland.start", function()
    hl.exec_cmd("PATH=" .. bin .. "omni-shim:$PATH omni-shell") -- shim: control-center slider drives the DDC monitor
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("swaybg -i /home/cjmnuss/Pictures/waves-light.jpg -m fill")
    hl.exec_cmd("wl-paste --type text --watch " .. bin .. "cliphist-next store")
end)

-- hyprmoncfg's generated monitor rules; must stay last
do local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
