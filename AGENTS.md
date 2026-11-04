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
| system updates | `unattended-update.timer` (`.root/`) + `proof-updates` | **Drata "auto-update"**: weekly Sun 18:00, AC-only, guarded — checkupdates-gated, **keyring first**, full `pacman -Syu`, journal = audit evidence, outcome toast always (with `.pacnew` count + post-run failed-units smoke check), fires **before** the 20:00 AV scan so the fresh system is scanned same evening. AUR/yay deliberately excluded (unattended PKGBUILD = code-exec risk). Arch has no supported unattended mechanism — this is the honest guarded approximation (gotcha below) |
| snapshots | snapper + snap-pac (`.root/etc/snapper/configs/root`, `.root/etc/snap-pac.ini`) | pre/post pair around EVERY pacman transaction (snap-pac 3 hooks, config "root"; pre hook AbortOnFail = uninsurable transactions abort); hourly count cleanup (`snapper-cleanup.timer`, 20 regular / 10 important); kernel pairs tagged important; timeline + boot snapshots + qgroups deliberately OFF (pacman = the change vector); **rollback = `sudo snapper rollback <n>` + reboot**; @home = kopia's domain. Scoping gotcha below; install/verify/undo + rollback test: `.root/README.md` |
| drata agent | AUR `drata-agent` + `drata-agent.service` (systemd user) | compliance reporter (Electron tray app + bundled osqueryi) — package ships NO Linux autostart (menu entry only), and this session has no XDG-autostart processor anyway (gotcha below). Autostart = supervised unit `WantedBy=graphical-session.target`, `Restart=always` — a crash self-heals in 3s, deliberate for a compliance agent (ghostty ships the same architecture vendor-side). The agent's in-app login toggle is broken on Arch (Electron `setLoginItemSettings` → junk `electron.desktop`, Exec = bare system electron — deleted; leave the toggle off, it would rewrite the junk). Cost: `PartOf=graphical-session` — no agent in pure-tty sessions |
| hyprlock PAM | `/etc/pam.d/hyprlock` (`.root/`) | pam_unix-only stack replacing the stock `auth include login` — Arch's system-auth faillock (compiled defaults deny=3/unlock_time=600; faillock.conf fully commented) made 3 fumbled unlock attempts lock the **account** for 10 min: correct password refused at hyprlock, TTY and sudo alike (2026-11-02, hit for real). sudo/su/TTY keep faillock — the lockscreen is not a login surface (LUKS = data boundary, tty1 autologin = login path). Break-glass: `sudo faillock --user cjmnuss --reset`, or reboot → autologin. Install/undo + upgrade-pacnew note: `.root/README.md` |
| AV (Drata) | clamav: `clamav-freshclam` + `clamav-daemon` services; weekly `clamav-scan.timer` (`.root/`) | compliance AV at near-zero cost: resident clamd (idle CPU ≈ 0; RAM holds the signature set), freshclam = conditional GET every 2h, weekly full scan **AC-only** (`ConditionACPower` — never on battery). **clamonacc deliberately off** — on-access is the real battery drainer and the control doesn't need it; Drata's device page is the ground truth, revisit if it ever demands real-time. `NotifyClamd` auto-reloads clamd after DB updates; scan excludes live in the repo-managed **full clamd.conf** (`.root/etc/clamav/clamd.conf` — clamd has no conf.d/include; edit → re-install → restart clamd; pacnew to reconcile on package upgrades). Install order + EICAR verify: `.root/README.md`. Drata evidence: `~/.local/bin/proof-antivirus` — transcript-style proof block (installed/running/enabled/timer/DB freshness), `--eicar` adds the detection proof with self-cleaning. **Detection → critical toast**: scan unit `OnFailure=` → `clamav-notify` (`/usr/local/sbin`, `.root/`) classifies detections-vs-error from the journal and toasts via runuser — no sudoers, no VirusEvent |
| containers | rootless podman + `podman-docker` CLI shim; kind via `KIND_EXPERIMENTAL_PROVIDER=podman` (zshrc) | daemonless fork/exec — no root, no docker socket (nothing ≡ root). pasta userspace networking: **never touches nftables** — needs the `tun` module at boot (`/etc/modules-load.d/tun.conf`, `.root/`). kind nodes run as user-namespace containers. Containers do NOT inherit the session: rbw/gpg-agent/Wayland sockets + `~` are invisible unless explicitly mounted — the mount list is the policy. Residual risk = kernel escape only; agent-sandbox escalation (gVisor `runsc` for that one container, or a minimal qemu VM for a disposable kernel — rootful podman inside is fine, the VM kernel is the boundary) is deliberate **phase 2**. **Storage**: all-btrfs machine → kernel overlay can't use btrfs as upperdir → `fuse-overlayfs` (`~/.config/containers/storage.conf`, chezmoi-managed); tax = image pulls + rootfs small-file writes (~2–3x); **named volumes + bind mounts bypass FUSE entirely** — hot caches belong in volumes. Escalation on measured pain: ext4 loop-image via `.root/` fstab (kernel overlay, native). The native btrfs graph driver is rootful-only (subvol ioctls are denied in userns) |

## Root-owned pieces → `.root/README.md`

- getty@tty1 autologin override — **installed** ✓
- `/etc/modules-load.d/i2c-dev.conf` — **installed** ✓
- kanata udev rule + uinput module-load — **installed** ✓
- `/etc/modules-load.d/tun.conf` (pasta/podman networking) — **installed** ✓
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
- **Weekly-scan triage (2026-11-03): "11 infected" = 11 explained, zero real** —
  2 eicar test files (/tmp, deleted), 5 Txt.Exploit.CopyFail hits in the
  owner's own CVE-research PoC repo, 4 Heuristics.Zip.OverlappingFiles
  in klauspost/compress's upstream fuzz fixtures. Recurring known-benign
  flags get ExcludePath'd (the research repo; Go module-cache `*.zip` —
  extracted module code stays scanned); the seadrive cloud mount stays
  IN scope (real ingress path). Alert fatigue is how AV dies: a weekly
  "5 detections" toast that's always the same PoCs trains you to ignore
  the real one. Scan noise is benign — "Not supported file type" on
  sockets, `cli_realpath` warnings, clamav's own racing /tmp temp files;
  "Total errors" ≠ detections.
- **Scan time is scope, not speed (2026-11-03)**: first full scan 26 min
  for ~900k files. Excluded (~451k → ~13 min, Drata-defensible):
  lockfile-pinned dependency trees (node_modules 156k, go/pkg/mod 133k,
  .pub-cache 37k, .cargo/registry 13k) and three zero-value cache
  subtrees (.cache/kopia 65k — AES-encrypted backup chunks, byte-verified
  ciphertext ClamAV cannot read; go-build 29k + gopls 18k — deterministic
  artifacts of scanned source). Deliberately kept IN scope: chromium 64k
  + yay 11k caches (real ingress: web content, AUR PKGBUILDs), all
  system/source/data. Caveat: any excluded path is a possible malware
  hideout — compensated by tool-owned high-churn dirs (kopia prunes, go
  evicts), inert binaries without persistence hooks (hooks live in
  scanned places: autostarts, rc files, systemd units), and the
  clamonacc lever if the threat model ever escalates. Brute-force
  alternative: `MaxThreads` in clamd.conf.
- **Arch has no supported auto-update** — Drata's toggle presumes
  Windows/macOS semantics. `unattended-update` is the guarded
  approximation: checkupdates-gated (pacman-contrib), keyring-first,
  AUR/yay excluded (unattended PKGBUILD = code-exec risk), failure
  toast + journal transcript, `.pacnew` count in the success toast
  (run pacdiff when it fires). Unattended upgrades still carry real
  risk — news-level manual interventions won't be read; the true
  safety net is btrfs snapshots (snapper — live since 2026-11-03, row
  above).
- **Snapshot domain scoping (snapper)** — snapshots cover @ only. The
  ESP (kernel + initramfs, separate vfat partition) is OUTSIDE the
  snapshot domain: rolling back @ after a kernel-updating Sunday can
  pair old `/usr/lib/modules` with the new vmlinuz/initramfs — the
  mismatch class. Rescue = ISO chroot + matching kernel reinstall;
  cheap standing fix = add `linux-lts` as a second kernel (backlog).
  systemd-boot has no snapshot boot menu (grub-btrfs is grub-only):
  `snapper rollback` needs a bootable system — the unbootable class
  stays with the Phase-3 ISO break-glass card. Timeline + boot
  snapshots + qgroups deliberately off (pacman pre/post is the change
  vector; chezmoi owns configs, kopia owns home).
- **XDG autostart is dead on this machine** — Arch's systemd ships no
  `systemd-xdg-autostart-generator` (a Debian patch, not upstream) and
  uwsm implements none: `~/.config/autostart/*.desktop` entries NEVER
  launch. Session autostart = systemd user units
  `WantedBy=graphical-session.target` (hypridle, udiskie, drata-agent;
  ghostty ships a vendor unit on the same route). Electron "launch at
  login" toggles also misfire on Arch: `setLoginItemSettings` writes
  `Exec=process.execPath` = the SYSTEM electron binary, app argument
  lost — a launcher that launches nothing, generically named "electron"
  (drata-agent did exactly this, 2026-11-03; junk file deleted — the
  in-app toggle would rewrite it, leave it off).
- **TUI background autodetection (OSC 11) was dead inside tmux** — claude
  code "detected a black background" on an all-Latte terminal: tmux doesn't
  answer pane OSC 11 queries by default (needs the `background` terminal
  feature, never auto-set for xterm-ghostty) and apps fall back to dark on
  silence. Fix in tmux.conf: `set -as terminal-features
  ',xterm-ghostty:background'` + `set -g allow-passthrough on`, then
  **re-attach** (tmux probes the outer terminal at client attach; options
  alone don't fire it). Probe from a pane: `printf '\e]11;?\a'` — a reply
  like `\e]11;rgb:efef/f1f1/f5f5` (latte) means tmux answered; a reply in a
  bare ghostty window only proves ghostty. OSC replies carry no newline —
  a line-buffered `read` after the probe reads back empty (the reply
  echoes then sits in the queue; C-u to clear).
- **A detection makes `clamav-scan.service` end "failed" (exit 1)** —
  that's clamdscan's documented exit code for "infected found", not a
  broken unit; the FOUND lines in `journalctl -u clamav-scan` are the
  evidence Drata wants. Detection-only by design: no `--move`/`--remove`
  in the unit — nothing quarantines or deletes; a human triages. The
  failure fires a **critical toast** since 2026-11-03
  (`OnFailure=clamav-notify.service` → `/usr/local/sbin/clamav-notify`
  → runuser → session bus, no sudoers entry, unlike the wiki's
  VirusEvent recipe). Manual clamdscan runs do NOT toast — only the
  weekly unit's failure.
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