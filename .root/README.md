# Root-owned config archive

Chezmoi only manages files under $HOME, so root-owned configs can't be
deployed by `chezmoi apply`. They live here instead — version-controlled,
mirroring their real absolute paths — and get installed manually with sudo.

## getty@tty1 autologin override

Installs a systemd drop-in that logs `cjmnuss` in on tty1 automatically at
boot. Combined with `~/.zprofile` (uwsm start hyprland-uwsm.desktop) this
boots straight into Hyprland with no typing. Security note: the lock screen
(hyprlock + hypridle) becomes the session's security boundary — which holds
only while no other VT stays logged in: a spare logged-in tty is a standing
bypass (2026-11-02: a days-old tty2 session was used to kill a wedged
hyprlock; logged out since). Rescue path for a wedged lock screen: a fresh
tty login (password-gated), then kill hyprlock — prefer `kill -9` (SIGKILL
leaves no coredump; kill -6's ABRT core later looks like a crash in
coredumpctl).

Install:

    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/getty@tty1.service.d/override.conf \
      /etc/systemd/system/getty@tty1.service.d/override.conf
    sudo systemctl daemon-reload

Undo:

    sudo rm -rf /etc/systemd/system/getty@tty1.service.d
    sudo systemctl daemon-reload

## i2c-dev kernel module (for ddcutil / ddcutil-service)

DDC/CI monitor control needs the `i2c_dev` kernel module. Without this file
it is not loaded at boot and external-display brightness (brightness-step
script) stops working until manually modprobed. Device access is granted to
the logged-in user by ddcutil's udev rules (60-ddcutil-i2c.rules) — no group
membership needed.

Install:

    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/modules-load.d/i2c-dev.conf \
      /etc/modules-load.d/i2c-dev.conf

Undo: remove that file.

## kanata uinput access

The kanata systemd user service creates a virtual keyboard via
`/dev/uinput`, which is root-only by default. The udev rule grants the
`uinput` group read/write access; the module-load file loads `uinput` at
boot. Group membership (`input` + `uinput`) is also required and only takes
effect after a new login.

Install:

    sudo groupadd --system uinput
    sudo usermod -aG input,uinput cjmnuss
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/udev/rules.d/99-input.rules \
      /etc/udev/rules.d/99-input.rules
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/modules-load.d/uinput.conf \
      /etc/modules-load.d/uinput.conf
    sudo udevadm control --reload && sudo udevadm trigger

Then log out/in (or reboot) for the group membership, and
`systemctl --user enable --now kanata`.

Verify: `ls -l /dev/uinput` shows `root:uinput` with mode `0660`, and
`systemctl --user status kanata` is active.

Undo: remove both files, drop the udev rule, `sudo gpasswd -d cjmnuss uinput`
(and optionally `sudo groupdel uinput`).

## SANE airscan scanner entry (Brother MFC-L8690CDW) — NOT installed (optional)

**Deliberately not installed**: scan-to-FTP from the printer is the primary
scan workflow, and PC pull-scanning works zero-config via airscan's built-in
WS-Discovery (no avahi, per-invocation, proven by a live test scan). Install
this entry only if discovery ever stops finding the scanner.

sane-airscan does NOT read `~/.config/sane.d/` — only `/etc/sane.d/airscan.conf`
counts, so the manual device entry (print.md) is root-side. The file is
package-owned and NOT in sane-airscan's backup array: a package upgrade
silently overwrites it — re-install from here after upgrades.

Install:

    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/sane.d/airscan.conf \
      /etc/sane.d/airscan.conf

Verify: `scanimage -L` lists the Brother.

Undo: `sudo rm /etc/sane.d/airscan.conf` — airscan then relies on its
built-in WS-Discovery, which still finds the scanner.

## hyprlock PAM stack (no pam_faillock)

The stock `/etc/pam.d/hyprlock` is `auth include login`, chaining into
system-auth's pam_faillock (compiled defaults: 3 failures within 15 min
lock the account for 600 s — even the correct password is refused, at
hyprlock, TTYs and sudo alike). A lockscreen is not a login surface —
the data boundary is LUKS and the login path is tty1 autologin anyway.
This stack verifies the local unix password and nothing else; sudo/su/
TTY keep their faillock.

Break-glass if you ever fail-lock yourself via the sudo/TTY paths:
from any open session run `sudo faillock --user cjmnuss --reset`, or
just reboot — tty1 autologin opens a session without PAM auth.

Install:

    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/pam.d/hyprlock \
      /etc/pam.d/hyprlock

Verify: lock, fumble the password 3 times, then type the correct one —
it must unlock immediately, and `faillock --user cjmnuss` stays empty.

Undo:

    echo 'auth include login' | sudo tee /etc/pam.d/hyprlock

The file is in hyprlock's backup array: on package upgrades pacman keeps
the local version and drops a `.pacnew` — compare, and re-install from
here if the package ever changes the shape of the stack.

## nftables firewall (laptop default-deny inbound)

The fw13 regularly sits on networks with **global IPv6** — directly
addressable, no NAT in front — so inbound is default-deny. Outbound is
free; loopback, established/related, DHCP replies and ICMP(v6) control
protocols pass. FORWARD stays policy-accept: the laptop isn't a router,
and a drop policy on that hook would break docker/kind container
networking (their FORWARD accepts live in ip-family chains on the same
hook). The config deliberately has **no `flush ruleset`** — it owns
exactly one table so reloads don't nuke other tools' rules in the same
netns.

Install (package `nftables` is in the package script):

    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/nftables.conf \
      /etc/nftables.conf
    sudo systemctl enable --now nftables

Verify (the service is a oneshot without RemainAfterExit — `systemctl
is-active nftables` reports inactive even with the rules loaded; the
ruleset is the ground truth):

    sudo nft list table inet filter

Reload after editing the file (idempotent — it destroys and re-creates
its own table):

    sudo nft -f /etc/nftables.conf

Undo:

    sudo systemctl disable --now nftables
    sudo nft destroy table inet filter
    sudo rm /etc/nftables.conf