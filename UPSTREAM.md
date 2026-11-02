# Upstream improvements to contribute / watch

Third-party behavior we work around locally (each has a matching workaround or
note in AGENTS.md or our configs). Contribute a fix/docs where possible; delete
the entry once upstream ships it and drop the local workaround.

## To contribute (issue / PR / docs)

- **omni-shell — hardcoded lowercase screenshot save path.**
  `NotificationService.qml:36` saves satty screenshots to `$HOME/pictures/...`
  (lowercase); it should use `$HOME/Pictures` or the XDG pictures dir so
  case-sensitive filesystems don't need the `~/pictures → ~/Pictures` symlink
  workaround.
  https://git.macocian.com/radumaco/omni-shell

- **omni-shell — no IPC target to open the notification center.**
  Extensions can't reach package singletons (NotificationService et al.), and
  there is no IPC hook, so the center can only be opened via the bar bell;
  expose an IPC target so keybinds/launchers can open it (draft in the Issue drafts section).
  https://git.macocian.com/radumaco/omni-shell

- **omni-shell — bell module visibility.**
  The bell only renders when history > 0 or DND is on; an always-visible bell
  with a blue unread state needs upstream module changes (draft in the Issue drafts section).
  https://git.macocian.com/radumaco/omni-shell

- **extrakto — Wayland clipboard auto-detection.**
  Auto-detection only checks `XDG_SESSION_TYPE == "wayland"`, which tmux session
  env often reports as `tty`, silently falling back to a missing `xclip` (exit
  127); prefer `wl-copy` when `WAYLAND_DISPLAY` is set.
  https://github.com/laktak/extrakto

- **tmux-tilish — document the smart-splits v3 backend split.**
  `@tilish-smartsplits` passthrough depends on the `@pane-is-vim` pane option,
  which smart-splits v3 core no longer sets — it now comes from the separate
  `smart-splits-nvim/backend-tmux` plugin; a note in the README would prevent
  silent breakage for v3 upgraders.
  https://github.com/jabirali/tmux-tilish

- **smart-splits.nvim — migration warning for `@pane-is-vim` consumers.**
  The v2→v3 migration guide should warn that removing built-in multiplexer
  support silently breaks `@pane-is-vim` integrations (tilish smartsplits mode,
  vim-tmux-navigator-style passthroughs).
  https://github.com/smart-splits-nvim/smart-splits.nvim

- **fuzzel — silent theme fallback on `rrggbb` colors.**
  Theme colors must be `rrggbbaa`; bare `rrggbb` silently falls back to the
  stock yellowish theme instead of erroring (or parsing both).
  https://codeberg.org/dnkl/fuzzel

- **wifitui — light/dark auto-detection inside tmux.**
  The `[light,dark]` auto-detection fails inside tmux, forcing a manual
  `--theme` override alias; make detection terminal-agnostic.
  https://github.com/shazow/wifitui

- **gnupg — `gpg-preset-passphrase --forget` broken?**
  `--forget` fails with "clearing passphrase failed: No inquire callback in
  IPC" on GnuPG 2.4.9 (`--preset` works fine); verify minimal repro and report.
  https://bugs.gnupg.org/ · https://github.com/gpg/gnupg

- **cliphist — cut a release for the merged entry-metadata work.**
  `list -fields id,timestamp`, `wipe -older-than` and proper unknown-flag errors
  (commit 673311f, closes #167) are on master while the latest tag is v0.7.0 —
  `go install go.senan.xyz/cliphist@latest` still builds v0.7.0 (verified), and
  the distro packages v0.7.0, so the README's expiry recipe can't work for
  users. Release-request draft in the Issue drafts section.
  https://github.com/sentriz/cliphist

- **cliphist — `contrib/cliphist-redact` recipe.**
  PR-ready: a python3 script that walks `list -fields id,timestamp` and deletes
  secret-shaped entries (API tokens, hex/numeric/base64 blobs, password shapes)
  with an `--min-age` grace window and `--dry-run`; fits the contrib/recipes
  ethos (pipes, not subcommands). Local copy: `~/.local/bin/cliphist-redact`.
  Draft in the Issue drafts section.
  https://github.com/sentriz/cliphist

- **wl-clipboard — release the clipboard-type propagation.**
  CLIPBOARD_TYPE / CLIPBOARD_STATE (PR #297) merged after v2.3.0 and still
  unreleased, so cliphist's MIME metadata + sensitive-clipboard handling is
  inert on any released wl-clipboard (distros ship 2.3.0). Release-request
  draft in the Issue drafts section.
  https://github.com/bugaevc/wl-clipboard

- **ddcutil-service — stale/empty display map, no self-recovery.**
  The daemon enumerates displays once at D-Bus activation, races the
  monitor's boot handshake (here: empty map one second after activation,
  then 6,830 failed calls over the whole boot), and never re-detects —
  every Get/SetVcp keeps answering status -3020 DDCRC_INVALID_DISPLAY
  (with busctl still exiting 0) until a forced `Detect` call. Ask: retry
  detection on demand, or invalidate on connectivity events.
  Local workaround: brightness-step and the slider set path force Detect
  and retry once (AGENTS.md gotchas); drop when fixed.
  https://github.com/digitaltrails/ddcutil-service

- **sane-airscan — no user-level config.** airscan reads only
  /etc/sane.d/airscan.conf; sane-backends itself supports
  $XDG_CONFIG_HOME/sane.d, and a root-owned file for a per-user scanner
  entry is overkill. Ask: honor the user config path too.
  Local consequence: the entry is root-side via `.root/` (print.md).
  https://github.com/alexpevzner/sane-airscan

- **cups-filters — ghostscript optdep makes driverless printing fail cryptically.**
  Every driverless queue that rasterizes dies with `gstoraster filter
  failed` until the optional ghostscript dependency is installed; the
  error names the filter, not the missing dep. Ask: hard dependency, or
  an actionable log line.
  https://github.com/OpenPrinting/cups-filters

- **hyprlock — stock PAM example inherits the whole login stack.**
  The shipped /etc/pam.d/hyprlock is `auth include login`; on distros
  where system-auth carries pam_faillock (Arch: deny=3, unlock_time=600),
  three fumbled unlock attempts DOS the owner account-wide for 10
  minutes. A lockscreen policy and a login policy shouldn't share a
  stack. Ask: ship or document a minimal pam_unix-only example for
  lock screens.
  https://github.com/hyprwm/hyprlock

## Already reported upstream (watch, drop workarounds when fixed)

- **hyprlock — SIGABRT on `dpms off` while locked.**
  hyprwm/hyprlock#984 / #991 / #953; until fixed, hypridle deliberately has no
  dpms listener and the suspend timeout darkens the screen instead.
  https://github.com/hyprwm/hyprlock/issues/984

- **cliphist — `list -fields` merged but unreleased.**
  Upstream master adds `list -fields` and proper unknown-flag errors; the
  distro still ships v0.7.0, so we build the pinned master (`cliphist-next`)
  until a release lands.
  https://github.com/sentriz/cliphist

- **ghostty — general slowness on Hyprland.**
  Requires the `async-backend = epoll` workaround.
  https://github.com/ghostty-org/ghostty/discussions/3224

- **hypridle — silent death after the hyprlock crash cascade.**
  Found dead on 2026-10-27, hours after the 10:15:59 hyprlock SIGABRT window:
  no coredump, no log line, cause unrecoverable. Now under systemd supervision
  (Restart=always), so a recurrence is a 3s blip — if it does recur, capture
  `journalctl --user -u hypridle` + a core and report.
  https://github.com/hyprwm/hypridle

## Issue drafts (ready to paste)

### omni-shell — IPC target for the notification center

> **Title: IPC target for the notification center**
>
> The center is reachable only by clicking the bar bell — there's no
> IpcHandler for it, so keybinding it isn't possible. `shell.qml` already
> wires NotificationService into `control` for DND and clear; the same shape
> would round it out:
>
> ```qml
> IpcHandler {
>     target: "notifications"
>     function toggle(): void { NotificationService.toggle(); }
>     function open(): void { if (!NotificationService.centerVisible) NotificationService.toggle(); }
>     function close(): void { NotificationService.closeCenter(); }
>     function clear(): void { NotificationService.clear(); }
> }
> ```
>
> Bonus: `clearToasts()` is also unreachable from outside — useful for
> scripts even though toasts auto-dismiss.
>
> Context: extensions can't fill this gap either. From an extension file the
> package singletons resolve as types, not instances — a `file:` URL
> directory import gives `NotificationService` with every member `undefined`
> (verified with a typeof diagnostic), single-file `file:` imports are
> rejected, and `qs.*` maps to quickshell's bundled library rather than the
> config root. So an IPC target is the only compositor-adjacent door for
> keybinds and launchers.

### omni-shell — bell bar module: always-visible option + blue-as-unread color

> **Title: Bell bar module: always-visible option + blue-as-unread color**
>
> `modules/Notifications.qml` hides the bell until history is non-empty,
> which makes the notification center undiscoverable on a quiet system — the
> only way in is a bell that isn't there. Two related suggestions:
>
> **1. Always-visible option.** A config key (e.g. `notificationsAlwaysVisible`,
> default `false` to keep today's behavior):
>
> ```qml
> visible: Config.notificationsAlwaysVisible
>     || NotificationService.history.count > 0
>     || NotificationService.dnd
> ```
>
> **2. Color as unread state.** The bell renders `Theme.active` whenever
> it's visible, which reads as "you have notifications" even when there are
> none. Suggested: active only when there is something to read:
>
> ```qml
> color: NotificationService.dnd ? Theme.idle
>     : (NotificationService.history.count > 0 ? Theme.active : Theme.idle)
> ```
>
> Happy to send a merge request for either or both if the direction is
> agreeable.

### sentriz/cliphist — release request

> **Title: Please cut a release — entry metadata (`list -fields`) is merged but untagged**
>
> The entry-metadata work (commit 673311f, closing #167) has been on master
> since September: `list -fields id,timestamp` (unix epoch seconds, empty for
> pre-metadata entries), `wipe -older-than`, and proper unknown-flag errors.
> The latest tag is still v0.7.0:
>
> - `go install go.senan.xyz/cliphist@latest` builds v0.7.0 (verified — no
>   timestamps, no flag validation)
> - distros package v0.7.0 (Arch extra), so none of this reaches users
> - the README's "Expire old entries" recipe references the unreleased
>   `-fields` flag, so the documented recipe cannot work on any release
>
> Please tag a release when practical.
>
> Side note: v0.7.0's silent unknown-flag handling means `cliphist wipe -h`
> performs a full wipe rather than printing usage — the merged flag errors
> fix that footgun too, another reason a release would help.

### sentriz/cliphist — `contrib/cliphist-redact` recipe PR

> **Title: Add `contrib/cliphist-redact` — heuristic secret redaction for the history**
>
> A python3 recipe that walks `cliphist list -fields id,timestamp` and
> deletes entries that look like secrets before they linger in the history:
>
> - token shapes (`xoxb-…`, `ghp_…`, `sk_live_…`, JWTs, `BEGIN PRIVATE KEY` …)
> - hex ≥16 chars, digit runs ≥6, base64 blobs ≥24 chars
> - password-shaped strings (no whitespace, ≥12 chars, 3+ character classes,
>   no long lowercase runs, letter-heavy with high character diversity)
> - `--min-age SECONDS` grace window (needs the entry timestamps — the
>   metadata work on master) so a just-copied password survives briefly
> - `--dry-run`, and a scratch-DB capability probe
>
> Calibrated against real password-manager / OTP clip traffic with an 11-case
> regression battery (URLs, IPs, UUIDs, package names all survive; tokens,
> keys, passwords all die).
>
> Positioned as a README recipe alongside `cliphist-fzf-sixel` rather than a
> subcommand, consistent with cliphist's pipes-not-pickers design.
> Contributed under GPL-3 to match the repo. Local copy:
> `~/.local/bin/cliphist-redact` — attach as `contrib/cliphist-redact`.

### bugaevc/wl-clipboard — release request

> **Title: Please cut a release — clipboard type/state propagation (PR #297) is merged but unreleased**
>
> CLIPBOARD_TYPE / CLIPBOARD_STATE propagation for `wl-copy` /
> `wl-paste --watch` was merged after v2.3.0 and no release has carried it
> since. Downstream consumers depend on it: cliphist's README documents the
> dependency ("requires wl-clipboard PR #297, merged after v2.3.0") and uses
> it for MIME metadata and sensitive-clipboard handling — all of which is
> inert on any released version, since distros package 2.3.0.
>
> Please cut a 2.4.x release when practical.

### dnkl/fuzzel — warn on 6-digit color values

> **Title: config: warn when a theme color is not 8-digit `rrggbbaa`**
>
> Theme colors in `fuzzel.ini` must be `rrggbbaa`; a bare `rrggbb` value is
> silently ignored and the whole theme falls back to the default — which
> cost real debugging time before the format requirement was identified.
> Either accepting 6-digit values (alpha = ff) or emitting a one-line warning
> on invalid color lengths would prevent the silent fallback.