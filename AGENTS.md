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

Bare-metal reinstall lives in `install/` (source-only, `.chezmoiignore`):
`fw13.json` is the proven manual runbook expressed as archinstall data
(LUKS2 + btrfs `@`+`@home`, swapless, sd-boot, `umask=0077` ESP),
`README.md` is the day-zero guide, `BRIDGE.md` is shell → this boot chain.
Not yet VM-proven — the open schema questions are listed there (Phase 2:
qemu + OVMF, same ISO version the USB carries).

## Session components

| Component | Config (all chezmoi-managed) | Notes |
|---|---|---|
| Hyprland (Lua config) | `~/.config/hypr/hyprland.lua` | binds, input (`compose:caps`), misc (Latte bg color, no animations, `focus_on_activate` so xdg-open'd files steal focus, `allow_session_lock_restore`), autostart. The `dofile` include from hyprmoncfg **must stay last** |
| hyprlock | `~/.config/hypr/hyprlock.conf` | required — v0.9.6 does NOT fall back to /usr/share |
| hypridle | `~/.config/hypr/hypridle.conf` + `~/.config/systemd/user/hypridle.service` + `~/.local/bin/idle-guard` | dim 2.5min; **5min: docked (external DP/HDMI) → screen off, no lock (coffee-proof); portable → lock** — hypridle has no conditional config, so idle-guard decides at fire time; 20min: docked lock (screen wakes first); suspend 30min. All listeners respect systemd inhibitors (caffeine tile). Runs as a **supervised systemd user service** (Restart=always) — an autostart line left it silently dead once (2026-10-27, after the hyprlock SIGABRT cascade); now a crash is a 3s respawn |
| kanata | `~/.config/kanata/main.kbd` + `~/.config/systemd/user/kanata.service` | home-row mods (a/s/d/f = ctrl/alt/meta/shift, mirrored on j/k/l/;). systemd user service (`default.target`). Hooks ONLY the internal keyboard via `linux-dev-names-include` **whitelist** — the old exclude list leaked the Kyria's Consumer/System-Control interfaces and the whole Unifying set (the MX Keys was getting home-row mods!). Compose stays with Hyprland's xkb `compose:caps` — kanata no longer does compose (mac setup removed). Needs uinput access: `.root/` udev rule + `input`/`uinput` groups (see `.root/README.md`) |
| omni-shell (quickshell) | `~/.config/omni-shell/config.json` (+`extensions/`) | bar, control center, toasts, notifications. Launched via autostart **with the shim PATH** (see gotchas) |
| omni-launcher | `~/.config/omni-launcher/config.json` | SUPER+D / SUPER+Space toggle |
| caffeine tile | `~/.config/omni-shell/extensions/caffeine.qml` | "Keep always on": toggles a `sleep:idle` systemd inhibitor (blocks suspend + all hypridle actions) |
| notifications | config.json keys | toast size = `fontSize`/`padding` (live-watched, no restart); `colors.glassBorder` draws the toast outline — the default is 10% white, invisible on Latte. Center opens via the **bar bell**, left-click (bell only appears when history > 0 or DND is on). SUPER+, clears toasts + history via `omni-shell-ipc control clearNotifications`. Keyboard-open and always-visible/blue-on-unread bell are both blocked on upstream — two issue drafts ready (IPC target + bell module behavior) |
| Wallpaper | `~/Pictures/waves-light.jpg` (NOT chezmoi-managed) | `swaybg -m fill` in autostart; solid Latte base color underneath as fallback |
| Brightness | `~/.local/bin/brightness-step` + `~/.local/bin/omni-shim/brightnessctl` | Fn keys → brightnessctl (internal, floored 10%) + ddcutil-service (ASUS over DDC/CI). The shim sits in quickshell's PATH so the control-center slider drives the ASUS; falls back to the internal panel when no DDC display. Both scripts validate the D-Bus reply's **status field** (busctl exits 0 even on daemon errors) and self-heal a stale ddcutil-service display map (forced `Detect` + one retry); the slider's 2s poll never Detects by design — fallback only |
| ddcutil-service | no config (session D-Bus, auto-activates; `pkill -x ddcutil-service` + any call respawns it) | needs `i2c_dev` at boot (`.root/etc/modules-load.d/i2c-dev.conf`, installed). Caches its display map from activation — races the monitor's boot handshake and can serve a stale/empty map (see gotchas) |
| ghostty | `~/.config/ghostty/config` | Nerd Font 10pt, `catppuccin-latte` theme (written by ghostty's in-app picker), padding, compose works via uwsm env |
| uwsm env | `~/.config/uwsm/env` | `GTK_IM_MODULE=simple` — GTK 4.20+ dropped its Wayland compose/dead-key fallback without an IME; this restores it for every GTK4 app (delete if ever installing fcitx5/ibus) |
| btop | `~/.config/btop/btop.conf` | SUPER+SHIFT+T system monitor, catppuccin-latte theme |
| fuzzel | `~/.config/fuzzel/fuzzel.ini` | Catppuccin Latte + JBMono 10pt; renders rofimoji's emoji picker and clipboard-pick's dmenu (SUPER+CTRL+V). Colors must be `rrggbbaa` — bare `rrggbb` silently falls back to the stock yellowish theme |
| wifitui | `~/.config/wifitui/theme.toml` + zshrc alias | single-color Catppuccin Latte theme (its `[light,dark]` auto-detection fails inside tmux); emoji icons need noto-fonts-emoji |
| yazi | `~/.config/yazi/theme.toml` (+ `Catppuccin-latte.tmTheme`) | terminal file browser, SUPER+SHIFT+F in ghostty. catppuccin/yazi latte-**mauve** (accent matches omni-shell); the `.tmTheme` gives Latte syntax colors in the preview pane |
| screenshots | `~/.local/bin/screenshot` | SUPER+P region, SUPER+SHIFT+P focused window (`region|window|all`). grim → `~/Pictures/Screenshots` + clipboard + thumbnail toast; toast click → satty via omni-shell's category-`screenshot` map |
| screen recording | `~/.local/bin/screenrecord` | gpu-screen-recorder toggle (`region|window|screen`), 60fps GPU MP4 → `~/Videos`, run again to stop. No bind by design; add `-a default_output` for desktop audio |
| kopia | `~/.local/bin/kopia-connect` | connects kopia to the Synology WebDAV repo: url/username/password from the `syno-nuss-roy` rbw item, repo password from `kopia-password`, path `/backup/kopia-<hostname>/` — one public script serves every machine. `~/.config/kopia/*` stays machine-local and must NEVER be chezmoi-managed (public repo; kopia writes its own files on connect). Idempotent; verifies with `kopia repository status` |
| printing | CUPS queue `MFC-L8690CDW` + `cups.socket` | driverless IPP Everywhere to the Brother MFC-L8690CDW (`ipp://Brother-L8690CDW-ClemJul/ipp/print`); system default via /etc/cups/lpoptions; web UI :631 auth = PAM/wheel (no cupsd accounts, no edits made). **ghostscript is load-bearing** (optdep of cups-filters). Full setup + recovery: `print.md` |
| scanning | scan-to-FTP from the printer (primary); sane-airscan + simple-scan (optional pull-scan) | **Primary: scan-to-FTP** — printer-initiated, configured on the MFC's console, nothing on this machine. PC pull-scan works **zero-config** (airscan built-in WS-Discovery, no avahi, proven by a live test scan); the deterministic WSD/IPv4 entry is archived in `.root/` but NOT installed — add it only if discovery ever flakes. airscan ignores `~/.config/sane.d/`; the /etc file is package-owned and upgrade-clobbered. Verify: `scanimage -L` |
| removable media | udisks2 + udiskie (`systemd/user/udiskie.service`) | automounts USB/SD to `/run/media/cjmnuss/<label>` **as the user's uid** (vfat uid=1000 — files owned by you, no root-owned card); internal disks excluded by udiskie's built-in `!is_external` rule (nvme/ESP never automount); devices already present at startup get mounted too; explicit `--automount --notify` (mount toasts via omni-shell). Runs as a supervised systemd user service, hypridle-style — a manually-started udiskie died silently with a broken env once. No config file; flags + defaults suffice. FAT labels matter: no label ⇒ UUID mountpoint (fix: `fatlabel`) |
| hyprlock PAM | `/etc/pam.d/hyprlock` (`.root/`) | pam_unix-only stack replacing the stock `auth include login` — Arch's system-auth faillock (compiled defaults deny=3/unlock_time=600; faillock.conf fully commented) made 3 fumbled unlock attempts lock the **account** for 10 min: correct password refused at hyprlock, TTY and sudo alike (2026-11-02, hit for real). sudo/su/TTY keep faillock — the lockscreen is not a login surface (LUKS = data boundary, tty1 autologin = login path). Break-glass: `sudo faillock --user cjmnuss --reset`, or reboot → autologin. Install/undo + upgrade-pacnew note: `.root/README.md` |

## Root-owned pieces → `.root/README.md`

- getty@tty1 autologin override — **installed** ✓
- `/etc/modules-load.d/i2c-dev.conf` — **installed** ✓
- kanata udev rule + uinput module-load — **installed** ✓
- `/etc/nftables.conf` firewall — **installed** ✓

## Operational gotchas (learned the hard way)

- **Restarting omni-shell must keep the shim**:
  `pkill -x quickshell; setsid -f sh -c 'PATH=$HOME/.local/bin/omni-shim:$PATH omni-shell'`
- omni-shell's extension watcher: the extensions dir must exist at shell
  start; editing an extension file reliably needs a shell **restart**
  (same-name swaps don't always trigger its rescan).
- A quickshell watcher dies silently if a watched config file is missing at
  launch — recreate the file, then restart the shell.
- hyprlock CRIT-exits without a user config; hypridle the same pattern.
- **hyprlock 0.9.6 SIGABRTs on `dpms off` while locked** (hyprwm/hyprlock#984/#991/#953) — invariant since 2026-11-02: hypridle's dpms-off (idle-guard docked branch, 5min) runs **unlocked only**, and every lock path (20min docked listener, after_sleep_cmd) wakes the screen first. Suspend darkens the screen by sleeping. Recovery from a TTY: `hyprctl eval 'hl.clear_crashed_lockscreen()'`, or just re-run `hyprlock` — allowed by `allow_session_lock_restore` in hyprland.lua. Beware: the crash-warning overlay can outlive the actual lock state (the session may already be unlocked).
- ddcutil VCP writes cost monitor NVRAM cycles — keep slider drags
  human-paced; the Fn keys use NO_VERIFY (single write).
- **ddcutil-service caches its display map from first activation** — it can
  race the monitor's boot handshake, enumerate an **empty** map, and then
  serve `status -3020 DDCRC_INVALID_DISPLAY` forever (6,830 failed calls
  over one boot here; keys silently dead because `busctl` **exits 0** on
  those — the error rides inside the reply). Validate the reply's status
  field (2nd-to-last word, `0` = OK), never the exit code. Self-heal:
  `busctl --user call com.ddcutil.DdcutilService /com/ddcutil/DdcutilObject
  com.ddcutil.DdcutilInterface Detect u 0`, then retry — built into
  brightness-step and the slider's set path; the slider's 2s poll
  deliberately never Detects (it would probe-loop on an undocked laptop).
  Drop the workaround when upstream self-recovers (UPSTREAM.md).
- **Router DNS serves flat names, never `.lan` FQDNs** —
  `Brother-L8690CDW-ClemJul` resolves (→ 192.168.63.30), `….lan` doesn't;
  avahi/mDNS is deliberately off. If the flat name ever flakes after a
  router reboot: `/etc/hosts` pin, or a DHCP reservation for `.30`. The
  scanner entry pins the IPv4 directly (print.md).
- **`ghostscript` is an optdep of cups-filters — driverless printing dies
  with `gstoraster filter failed` without it** (plus `gsfonts`). Failed
  jobs park in the queue: `cancel <queue>-<id>` before reprinting.
- **sane-airscan ignores `~/.config/sane.d/`** — only `/etc/sane.d/airscan.conf`
  counts, and that file is package-owned and NOT in the backup array:
  package upgrades silently clobber it → re-install from `.root/` (that
  pattern exists for exactly this class of problem).
- **hyprlock fail-locked the account via Arch's login chain** — stock
  `auth include login` → system-auth's pam_faillock (defaults: 3 fails
  within 15 min → 10-min lockout of the *correct* password, account-wide
  across hyprlock/TTY/sudo). Fixed with the pam_unix-only stack in
  `.root/etc/pam.d/hyprlock`; `faillock --user cjmnuss` shows state,
  `sudo faillock --user cjmnuss --reset` clears it. Sudo/TTY still
  faillock: fumbling sudo 3× has the same 10-min lockout (accepted —
  the break-glass is the reset command or a reboot → autologin).
- **A logged-in spare VT is a standing lockscreen bypass** — 2026-11-02:
  a days-old tty2 session allowed a wedged hyprlock to be killed from its
  shell, no password asked. (The 08:27:56 "hyprlock crash" in coredumpctl
  is that deliberate kill — SIGABRT — not a bug: kill -6/ABRT leaves a
  core that looks like a crash later; **kill -9 leaves no core** — use it
  for deliberate kills so the forensics stay honest.) Rule: log out of
  spare VTs; the rescue path for a wedged lock screen is a *fresh* tty
  login (password-gated — a rescue, not a bypass), then kill hyprlock.
- **Firewall = plain nftables** (`/etc/nftables.conf`, source in `.root/`):
  default-deny inbound, outbound free — global-IPv6 networks make the laptop
  directly addressable, so keep it. The config owns exactly one table and has
  **no `flush ruleset`** on purpose: reloads must not nuke docker/kind's
  ip-family rules in the same netns (reload is idempotent via
  `destroy table inet filter` first). FORWARD is policy-accept: not a router,
  and a drop policy on the same hook would double-block docker's FORWARD
  accepts. Unsolicited mDNS stays blocked (one-liner in the file if discovery
  is ever wanted). `systemctl is-active nftables` reports **inactive even when
  loaded** — the unit is oneshot without RemainAfterExit; the ruleset itself
  is the ground truth (`sudo nft list table inet filter`).
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
- **`sudo systemctl --user …` never works**: sudo's env-reset strips
  `$DBUS_SESSION_BUS_ADDRESS` and `$XDG_RUNTIME_DIR`, so systemctl can't
  reach the user bus ("Failed to connect to user scope bus…"). User units
  never need sudo — plain `systemctl --user`. And ddcutil-service isn't a
  unit at all: it's D-Bus auto-activated — `pkill -x ddcutil-service` plus
  any busctl call respawns it fresh.
- **gpg-agent preset passphrases are capped by `max-cache-ttl`** (2h default) —
  overnight suspends burned them, which is why gpg-unlock kept needing re-runs.
  The gpg-preset-passphrase(1) "don't expire" wording is misleading; the TTL
  cap wins (and a SIGHUP/`gpgconf --reload gpg-agent` flushes presets too —
  re-run gpg-unlock after changing agent options). Raised to 30d in
  `~/.gnupg/gpg-agent.conf` ≈ "until reboot"; still RAM-only.
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