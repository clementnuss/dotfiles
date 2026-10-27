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