# Root-owned config archive

Chezmoi only manages files under $HOME, so root-owned configs can't be
deployed by `chezmoi apply`. They live here instead — version-controlled,
mirroring their real absolute paths — and get installed manually with sudo.

## getty@tty1 autologin override

Installs a systemd drop-in that logs `cjmnuss` in on tty1 automatically at
boot. Combined with `~/.zprofile` (uwsm start hyprland-uwsm.desktop) this
boots straight into Hyprland with no typing. Security note: the lock screen
(hyprlock + hypridle) becomes the session's security boundary.

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