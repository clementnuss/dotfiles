# fw13 bare-metal install (archinstall)

The manual runbook from install run #1 (LUKS2/btrfs laptop, proven, gotchas
baked in) expressed as **archinstall data**. Scope: bare metal → reboot into
a login shell. `BRIDGE.md` takes over from there. This file supersedes the
stored runbook note; the recovery recipe at the bottom stays manual by design.

**Status: modeled on archinstall's shipped `examples/config-sample.json`, NOT
yet VM-proven.** Phase 2 (qemu + OVMF, same ISO version the USB carries)
validates the open questions listed at the bottom before any real disk is
wiped. `fw13.json` contains no secrets — credentials never enter this repo.

## What each runbook step became

| runbook step | archinstall key |
|---|---|
| `sgdisk` ESP 1G + cryptroot | `disk_config` manual partitioning; `boot` flag sets the ESP GUID |
| `luksFormat --type luks2 --pbkdf argon2id` | `disk_encryption` on the root partition's `obj_id` (argon2id is cryptsetup's LUKS2 default — verify at VM) |
| btrfs `@`+`@home` only, `zstd:1`, `noatime` | `btrfs` subvolume list + `mount_options` |
| swapless, no zram | `swap.enabled: false` |
| pacstrap + CPU-vendor line | `packages` |
| genfstab + `umask=0077` (gotcha #2) | ESP `mount_options` — declarative |
| chroot locale/timezone/hostname/vconsole | `locale_config`, `timezone`, `hostname` |
| mkinitcpio HOOKS (gotcha #1) | archinstall generates them — verify, never author |
| bootctl + heredoc entry (gotcha #3) | `bootloader_config` Systemd-boot — no heredoc to quote wrong |
| useradd -m -G wheel -s /bin/zsh | `--creds` file: `users: [{sudo: true, …}]` |
| systemctl enable NetworkManager | `network_config` network_manager |

## Day zero

0. **Pre-flight**: backups current + restore smoke-test passed (a backup
   never restored is not a backup). USB with the ISO + this directory.
   `lsblk` — verify `/dev/nvme0n1`; never assume.
1. **Network** (manual by design): `iwctl --passphrase "…" station wlan0
   connect "SSID"` or ethernet. Then `timedatectl set-ntp true`.
2. **Mirrors**: `reflector --country switzerland --country germany
   --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist`
   (archinstall inherits the ISO mirrorlist — `mirror_config` deliberately
   absent so no stale URL list lives in this file).
3. Copy this `install/` directory from the USB.
4. **Write the creds file** — secrets never touch the repo or the USB
   afterwards:
   ```json
   {
     "!encryption-password": "<LUKS passphrase>",
     "users": [
       {"sudo": true, "username": "cjmnuss", "enc_password": "<hash>"}
     ]
   }
   ```
   Hash: `openssl passwd -6` (prompts for the login password, prints the
   SHA-512 crypt hash). No `root_enc_password` — root stays locked, as in
   the manual runbook.
5. **Install**: `archinstall --config fw13.json --creds fw13-creds.json
   --silent`. Wipes `/dev/nvme0n1`. Logs land in `/var/log/archinstall`
   (full transparency, on the ISO and partially on the installed system).
6. `shred -u fw13-creds.json` → `reboot` → pull the USB. Expect the busybox
   LUKS prompt right after kernel messages (US keymap types normally) →
   hostname login → shell.

## First-boot verification (the old "eyeball it" step, kept)

- `cryptsetup luksDump /dev/nvme0n1p2` → LUKS2, PBKDF **argon2id**
- `grep ^HOOKS /etc/mkinitcpio.conf` → base udev … **encrypt** … and NO
  `systemd`/`sd-*` (run #1's trap: a hybrid set silently skips the unlock →
  90s start-job timeout)
- `/etc/fstab`: ESP line has `umask=0077`; `/` and `/home` have
  `subvol=@`/`subvol=@home`, `noatime`, `compress=zstd:1`
- `/boot/loader/entries/arch.conf`: `cryptdevice=UUID=<p2 UUID>:cryptroot`,
  `rootflags=subvol=@`
- `swapon --show` empty, no zram unit (one swap mechanism ever; hibernate
  later = btrfs swapfile inside LUKS)
- User shell: `chsh -s /bin/zsh cjmnuss` if archinstall defaulted to bash
- Then follow `BRIDGE.md`

## Per-machine copies

`fw13.json` IS the parameters block. New machine: copy the file, edit
`device`, `hostname`, `packages` (CPU-vendor line: AMD = the list as-is;
Intel = `intel-ucode mesa vulkan-intel intel-media-vaapi`; other = stop and
think). The `obj_id`s can stay — they're internal references between
`disk_config` and `disk_encryption`, not real partition UUIDs.

## Recovery recipe (stays manual — it's for broken systems)

ISO → `cryptsetup open /dev/nvme0n1p2 cryptroot` → mount
`-o subvol=@ /dev/mapper/cryptroot /mnt` (+ `subvol=@home` → `/mnt/home`,
`p1` → `/mnt/boot`) → `arch-chroot /mnt`. Cmdline-only fixes (typo in the
boot entry) need no `mkinitcpio -P`; HOOKS changes do.

## Run #1 gotchas → who owns them now

1. **Hybrid HOOKS = silent no-unlock**: archinstall generates the hooks;
   the first-boot check above still eyeballs them.
2. **World-readable ESP warning**: declarative — `mount_options:
   ["umask=0077"]`.
3. **Unquoted heredoc for the UUID**: gone — archinstall writes the entry.
4. **`pacman -Qqen` from an omarchy box lies** (omarchy's custom repo
   registers AUR packages as native): still true — only reuse package lists
   from a clean-machine run, never from a contaminated host.
5. **One swap mechanism ever**: `swap.enabled: false`; the future hibernate
   path stays the btrfs swapfile inside LUKS, not zram.

## Open until the VM proof (Phase 2 validates exactly these)

- `"size": {"unit": "percent", "value": 100}` for the root partition — the
  shipped sample only shows absolute sizes; if the ISO rejects it, replace
  with the absolute value from `lsblk`.
- `"network_config": {"type": "network_manager"}` — the sample shows
  `"manual"`; confirm the NM string.
- `"swap": {"enabled": false}` object form (the guided docs page showed a
  bare boolean — the sample shows the object).
- creds key `"!encryption-password"` (from the docs table;
  `creds-sample.json` omits it) — if silent mode prompts instead of reading
  it, answer interactively once and record the outcome here.
- `"version"` key omitted — if the ISO's archinstall demands one, add the
  value `archinstall --version` reports.
- argon2id as the tool's luksFormat default (luksDump check above).
- zsh as the created user's default shell (fallback: the `chsh` line).