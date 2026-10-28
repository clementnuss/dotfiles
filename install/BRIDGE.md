# fw13 bridge: login shell → full desktop

First boot after `README.md`. Chezmoi does ~90% of the work; this is the
ordered path. Bitwarden is the single root of trust: rbw holds the GitHub
credential-free clone needs (none — the repo is public), the kopia secrets,
and everything restored later.

1. Login as `cjmnuss`. Network first: `nmtui` for wifi (NetworkManager is
   enabled by the install) or plug ethernet.
2. `sudo pacman -S --needed rbw git chezmoi`
3. Configure + unlock rbw (self-hosted vault — the two config values are
   memorized, they are the bootstrap):
   ```sh
   rbw config set base_url <vault-url>
   rbw config set email <account-email>
   rbw unlock        # if pinentry is missing: sudo pacman -S pinentry
   ```
4. Clone + apply the dotfiles — public repo, **no credential needed**:
   ```sh
   chezmoi init --apply https://github.com/clementnuss/dotfiles.git
   ```
   The `run_onchange` package script runs on this first apply and installs
   the official-repo half of the desktop stack (it will prompt for the sudo
   password mid-apply — normal). The AUR half is skipped: no helper yet.
5. AUR helper, one-time build:
   ```sh
   sudo pacman -S --needed base-devel
   git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
   ```
6. Re-run the package script now that yay exists, so the AUR list installs
   (kopia-bin and the rest):
   ```sh
   chezmoi execute-template < ~/.local/share/chezmoi/run_onchange_install-packages.sh.tmpl | bash
   ```
7. User services (files arrived via apply; enabling is the one-liner):
   ```sh
   systemctl --user daemon-reload && systemctl --user enable --now hypridle
   ```
   kanata comes later — it needs the udev rule + groups from `.root/README.md`.
8. **Kopia** — all secrets from rbw, repository files stay machine-local:
   ```sh
   kopia-connect
   ```
   Idempotent; prints `kopia repository status` on success. A brand-new
   machine with no repo yet does `kopia repository create webdav …` once
   instead — a deliberate human decision (repo password choice).
9. Data restore, as needed: `kopia snapshot list` →
   `kopia restore <snapshot-id>/<path> ~/<path>` — `~/.ssh` first (git push
   access), then browser profile, `~/git` clones, `~/Pictures`. The kopia
   restore of `~/.config` also makes step 3's manual rbw config permanent.
10. `reboot` → login on tty1 → `~/.zprofile` execs
    `uwsm start hyprland-uwsm.desktop` → the boot chain from AGENTS.md.
11. Smoke checklist (the AGENTS.md gotchas as a test list): bar + toasts
    render, SUPER+P screenshot lands in `~/Pictures/Screenshots`,
    SUPER+CTRL+V clipboard picker (and the redact timer), SUPER+, clears
    notifications, fuzzel pickers at full width, xdg-open'd files steal
    focus, SUPER+SHIFT+E exits and autologin respawns the session.

Not automated, deliberately: browser logins, GPG key import (kopia restore),
rbw first-boot config (step 3), push access to the dotfiles repo (restore
`~/.ssh` via kopia first, or add the new machine's key on GitHub).