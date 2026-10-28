# Clément Nussbaumer's dotfiles

Multi-machine chezmoi repo. This README stays in the source only
(`.chezmoiignore` keeps it out of the target home).

## Machines

- **fw13-cjmnuss** — Framework 13 (AMD Ryzen AI 300), Arch Linux, Hyprland.
  Minimal, explainable, Catppuccin **Latte** (light). This section documents it.

## Boot chain (fw13)

LUKS → getty@tty1 **autologin** (root override, see `.root/README.md`) →
zsh login shell → `~/.zprofile` (`uwsm check may-start` guard) →
`uwsm start hyprland-uwsm.desktop` → Hyprland (Lua config) → autostart.

Consequences: SUPER+SHIFT+E (`uwsm stop`) drops out, agetty respawns,
autologin fires, the session **restarts within seconds** — to get a plain
shell, log in on tty2. The lock screen is the security boundary when the
machine is idle/suspended; the LUKS passphrase is the boot boundary.

## Session components

| Component | Config (all chezmoi-managed) | Notes |
|---|---|---|
| Hyprland (Lua config) | `~/.config/hypr/hyprland.lua` | binds, input (`compose:caps`), misc (Latte bg color, no animations, `focus_on_activate` so xdg-open'd files steal focus, `allow_session_lock_restore`), autostart. The `dofile` include from hyprmoncfg **must stay last** |
| hyprlock | `~/.config/hypr/hyprlock.conf` | required — v0.9.6 does NOT fall back to /usr/share |
| hypridle | `~/.config/hypr/hypridle.conf` + `~/.config/systemd/user/hypridle.service` | dim 2.5min, lock 5min, suspend 30min. All listeners respect systemd inhibitors. Runs as a **supervised systemd user service** (Restart=always) — an autostart line left it silently dead once (2026-10-27, after the hyprlock SIGABRT cascade); now a crash is a 3s respawn |
| kanata | `~/.config/kanata/main.kbd` + `~/.config/systemd/user/kanata.service` | home-row mods (a/s/d/f = ctrl/alt/meta/shift, mirrored on j/k/l/;). systemd user service (`default.target`). Compose stays with Hyprland's xkb `compose:caps` — kanata no longer does compose (mac setup removed). Needs uinput access: `.root/` udev rule + `input`/`uinput` groups (see `.root/README.md`) |
| omni-shell (quickshell) | `~/.config/omni-shell/config.json` (+`extensions/`) | bar, control center, toasts, notifications. Launched via autostart **with the shim PATH** (see gotchas) |
| omni-launcher | `~/.config/omni-launcher/config.json` | SUPER+D / SUPER+Space toggle |
| caffeine tile | `~/.config/omni-shell/extensions/caffeine.qml` | "Keep always on": toggles a `sleep:idle` systemd inhibitor (blocks suspend + all hypridle actions) |
| notifications | config.json keys | toast size = `fontSize`/`padding` (live-watched, no restart); `colors.glassBorder` draws the toast outline — the default is 10% white, invisible on Latte. Center opens via the **bar bell**, left-click (bell only appears when history > 0 or DND is on). SUPER+, clears toasts + history via `omni-shell-ipc control clearNotifications`. Keyboard-open and always-visible/blue-on-unread bell are both blocked on upstream — two issue drafts ready (IPC target + bell module behavior) |
| Wallpaper | `~/Pictures/waves-light.jpg` (NOT chezmoi-managed) | `swaybg -m fill` in autostart; solid Latte base color underneath as fallback |
| Brightness | `~/.local/bin/brightness-step` + `~/.local/bin/omni-shim/brightnessctl` | Fn keys → brightnessctl (internal, floored 10%) + ddcutil-service (ASUS over DDC/CI). The shim sits in quickshell's PATH so the control-center slider drives the ASUS; falls back to the internal panel when no DDC display |
| ddcutil-service | no config (session D-Bus, auto-activates) | needs `i2c_dev` at boot (`.root/etc/modules-load.d/i2c-dev.conf`, installed) |
| ghostty | `~/.config/ghostty/config` | Nerd Font 10pt, `catppuccin-latte` theme (written by ghostty's in-app picker), padding, compose works via uwsm env |
| uwsm env | `~/.config/uwsm/env` | `GTK_IM_MODULE=simple` — GTK 4.20+ dropped its Wayland compose/dead-key fallback without an IME; this restores it for every GTK4 app (delete if ever installing fcitx5/ibus) |
| btop | `~/.config/btop/btop.conf` | SUPER+SHIFT+T system monitor, catppuccin-latte theme |
| fuzzel | `~/.config/fuzzel/fuzzel.ini` | Catppuccin Latte + JBMono 10pt; renders rofimoji's emoji picker and clipboard-pick's dmenu (SUPER+CTRL+V). Colors must be `rrggbbaa` — bare `rrggbb` silently falls back to the stock yellowish theme |
| wifitui | `~/.config/wifitui/theme.toml` + zshrc alias | single-color Catppuccin Latte theme (its `[light,dark]` auto-detection fails inside tmux); emoji icons need noto-fonts-emoji |
| yazi | `~/.config/yazi/theme.toml` (+ `Catppuccin-latte.tmTheme`) | terminal file browser, SUPER+SHIFT+F in ghostty. catppuccin/yazi latte-**mauve** (accent matches omni-shell); the `.tmTheme` gives Latte syntax colors in the preview pane |
| screenshots | `~/.local/bin/screenshot` | SUPER+P region, SUPER+SHIFT+P focused window (`region|window|all`). grim → `~/Pictures/Screenshots` + clipboard + thumbnail toast; toast click → satty via omni-shell's category-`screenshot` map |
| screen recording | `~/.local/bin/screenrecord` | gpu-screen-recorder toggle (`region|window|screen`), 60fps GPU MP4 → `~/Videos`, run again to stop. No bind by design; add `-a default_output` for desktop audio |

## Root-owned pieces → `.root/README.md`

- getty@tty1 autologin override — **installed** ✓
- `/etc/modules-load.d/i2c-dev.conf` — **installed** ✓
- kanata udev rule + uinput module-load — **pending install** (see `.root/README.md`)

## Operational gotchas (learned the hard way)

- **Restarting omni-shell must keep the shim**:
  `pkill -x quickshell; setsid -f sh -c 'PATH=$HOME/.local/bin/omni-shim:$PATH omni-shell'`
- omni-shell's extension watcher: the extensions dir must exist at shell
  start; editing an extension file reliably needs a shell **restart**
  (same-name swaps don't always trigger its rescan).
- A quickshell watcher dies silently if a watched config file is missing at
  launch — recreate the file, then restart the shell.
- hyprlock CRIT-exits without a user config; hypridle the same pattern.
- **hyprlock 0.9.6 SIGABRTs on `dpms off` while locked** (hyprwm/hyprlock#984/#991/#953) — hypridle deliberately has NO dpms listener; the 30min suspend darkens the screen instead. Recovery from a TTY: `hyprctl eval 'hl.clear_crashed_lockscreen()'`, or just re-run `hyprlock` — allowed by `allow_session_lock_restore` in hyprland.lua. Beware: the crash-warning overlay can outlive the actual lock state (the session may already be unlocked).
- ddcutil VCP writes cost monitor NVRAM cycles — keep slider drags
  human-paced; the Fn keys use NO_VERIFY (single write).
- **cliphist v0.7.0 silently ignores unknown flags** — `cliphist wipe -h`
  is a full wipe (learned the hard way). Probe capabilities with
  `-db-path` on a scratch DB, never the live one. Upstream master (merged,
  unreleased) adds `list -fields id,timestamp` and proper flag errors; until
  the distro ships it, the autostart watcher and cliphist-redact use
  `~/.local/bin/cliphist-next` (master build, pinned sha, built by the
  run_onchange package script). Delete it once the distro cliphist has
  `-fields` — the scripts fall back to `cliphist` automatically. Note:
  `go install ...@latest` still gets v0.7.0; the sha pin is load-bearing.
- `pkill -f` patterns match your own shell's command line — a compound
  command containing the pattern kills its own shell mid-run (happened
  twice). Kill by exact name (`pkill -x wl-paste`) or restart in a
  separate command from the pattern you're matching.
- **zsh ties lowercase `path` to `$PATH`** (`typeset -T path PATH`): using
  `path` as a scratch variable (e.g. `read -r a b path c`) silently rewrites
  PATH, and every later external command in the script fails with "command
  not found" (bit me while diagnosing tmux panes; `path` is an ordinary
  name in bash).
- **tmux panes keep their birth env forever**: the server was started from
  a TTY (no `WAYLAND_DISPLAY`), so panes born before the first in-session
  attach never see it — `update-environment` only repairs the global env
  for NEW panes. Fix stale panes with
  `export WAYLAND_DISPLAY=wayland-1 DISPLAY=:0` (the Hyprland socket is
  `wayland-1`, never `wayland-0`), or just open a new pane. The conf
  already lists both vars in update-environment.
- **`~/pictures` is a symlink to `~/Pictures`** — omni-shell's package QML
  hardcodes satty's save path as `$HOME/pictures/...` (lowercase,
  NotificationService.qml:36). We don't patch package files; the symlink
  makes their code write to the real directory. Delete it if upstream ever
  fixes the path.
- **omni-shell extensions cannot reach package singletons** (NotificationService
  & co.): a `file:` URL directory import resolves the *type* — every member
  reads `undefined` (verified with a typeof diagnostic in the log); single-file
  `file:` imports are rejected outright; `qs.*` maps to quickshell's bundled
  library, not the config root. Extensions are data + `activate()` + Process
  only. This is why a keybind that opens the notification center needs an
  upstream IPC target (issue drafted).
- quickshell mirrors its log to
  `/run/user/1000/quickshell/by-id/<id>/log.qslog` — read extension load
  errors there instead of restarting blind.
- **`kill` with an empty/unresolved pid is self-destruction**: `pid=$(systemctl
  show -p MainPID --value unit)` without `--user` queries PID 1's manager,
  returns 0 for a user unit, and `kill -9 0` signals your own process group —
  the shell dies mid-command. Guard pid reads (`[ "$pid" -gt 0 ]`) and remember
  the `--user` scope.
- Compose key = **Caps Lock** (Caps + ' + e → é). Works in GTK apps only
  thanks to the uwsm env above; Chromium/Qt do their own.
- `hyprmoncfg-monitors.lua` is intentionally NOT chezmoi-managed — the
  daemon rewrites it.
- The whole `.root/` directory is archive-only: chezmoi ignores dot-entries,
  root installs them manually per `.root/README.md`.

## Packages

`run_onchange_install-packages.sh.tmpl` holds the full list (official + AUR)
including the Hyprland desktop stack. Editing the list changes the script's
hash, so the next `chezmoi apply` re-runs it — everything is installed with
`--needed`, so it is idempotent.

## Uncommitted work

This repo accumulates work; commit often:
`git -C ~/.local/share/chezmoi add -A && git -C ~/.local/share/chezmoi commit`