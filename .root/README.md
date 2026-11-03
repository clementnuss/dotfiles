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

## tun kernel module (for pasta / rootless podman networking)

pasta (rootless podman networking) creates a tap device via `/dev/net/tun`.
Arch builds `tun` as a module and nothing else on this machine loads it,
so without this file the device sits driverless and every `podman run`
fails with "Failed to open() /dev/net/tun: No such device". Note: after a
kernel update the module for the *running* kernel is gone from
`/lib/modules` until reboot — if the error reappears with
`modinfo: Module tun not found`, reboot first (kernel/modules mismatch),
then re-check.

Install:

    sudo modprobe tun
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/modules-load.d/tun.conf \
      /etc/modules-load.d/tun.conf

Verify: `ls /dev/net/tun` exists and `podman run --rm quay.io/podman/hello`
prints its hello message.

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

## ClamAV (Drata compliance AV)

Enabled set (all root-side): `clamav-freshclam.service` (signature DB,
conditional HTTP GET every 2h — no measurable battery cost),
`clamav-daemon.service` (resident clamd; idle CPU ≈ 0, costs RAM for the
signature set), and a **weekly scan that only runs on AC**
(`ConditionACPower=true` — compliance without battery drain).
`clamav-clamonacc` (on-access scanning) is deliberately NOT enabled: it
is the actual battery drainer (scans every file open/write) and the
control doesn't need it. Drata's device page is the ground truth —
check what the agent reports; if a stricter reading ever demands
on-access, revisit with eyes open.

Install, in order (clamd.conf is repo-managed as a FULL file — clamd has
no conf.d/include mechanism, so `.root/etc/clamav/clamd.conf` is the
single source of truth: edit it in the repo, re-install, restart clamd;
the workflow and the pacnew-reconciliation note live in the file's
header comment):

    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/clamav/clamd.conf \
      /etc/clamav/clamd.conf
    sudo systemctl enable --now clamav-freshclam.service
    # wait for the first DB download (~1GB, minutes) — check: ls /var/lib/clamav
    sudo systemctl enable --now clamav-daemon.service
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/clamav-scan.service \
      /etc/systemd/system/clamav-scan.service
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/clamav-scan.timer \
      /etc/systemd/system/clamav-scan.timer
    sudo systemctl daemon-reload
    sudo systemctl enable --now clamav-scan.timer

Verify: `systemctl is-active clamav-freshclam clamav-daemon`, and the
definitive end-to-end proof — the industry-standard harmless test
signature (freshclam.conf's NotifyClamd already reloads clamd after DB
updates, so no restart needed):

    curl -s https://secure.eicar.org/eicar.com -o /tmp/eicar.com
    sudo clamdscan --multiscan --fdpass /tmp/eicar.com   # expect: Infected files: 1

A detection changes nothing on disk: clamdscan prints the FOUND line and
exits 1 — so the weekly unit ends "failed" (documented exit codes:
0 clean, 1 infected, 2 error) — and the FOUND lines in
`journalctl -u clamav-scan` are the evidence. No quarantine/delete by
design: the unit passes no `--move`/`--remove`; a human triages — the
notification below is the heads-up, the journal is the record. Delete
the eicar file after testing (or reboot — /tmp is tmpfs), or the
weekly scan will honestly report it forever.

Notification (2026-11-03): the scan unit carries
`OnFailure=clamav-notify.service` — a failed weekly run sends a
**critical desktop toast** via `/usr/local/sbin/clamav-notify`, which
classifies exit-1 (detections, counted from the 48h journal window)
vs exit-2 (error) and delivers through each logged-in user's session
bus via runuser. No sudoers changes (the Arch wiki's VirusEvent recipe
would need a NOPASSWD entry for the clamav user — deliberately avoided).
Manual clamdscan runs do NOT toast — only the weekly unit's failure.

    sudo install -m 755 \
      ~/.local/share/chezmoi/.root/usr/local/sbin/clamav-notify \
      /usr/local/sbin/clamav-notify
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/clamav-notify.service \
      /etc/systemd/system/clamav-notify.service
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/clamav-scan.service \
      /etc/systemd/system/clamav-scan.service
    sudo systemctl daemon-reload

Quick test: `sudo /usr/local/sbin/clamav-notify` → a toast arrives (with
no scan run yet it says "scan failed / no detections" — honest for its
inputs). Full end-to-end: leave the eicar file in /tmp, run
`sudo systemctl start clamav-scan.service` (real full scan, minutes),
and expect the "Antivirus: 1 detection(s)" toast on completion.

Drata evidence screenshot (single shot, all verified — the `date` line
timestamps the evidence itself). Run by hand: `proof-antivirus`
(chezmoi-managed, `dot_local/bin/`) prints this whole block
transcript-style — each command echoed before its output, so the
screenshot shows what was run and what it returned; `--eicar` appends
the detection proof (fetches the test file, scans, self-cleans);
`| tee av.txt` keeps a text artifact alongside. Manual block:

    date
    pacman -Q clamav
    systemctl is-active clamav-freshclam clamav-daemon
    systemctl is-enabled clamav-freshclam clamav-daemon clamav-scan.timer
    systemctl list-timers --no-pager clamav-scan.timer | head -3
    ls -l /var/lib/clamav/

proves: installed (name+version), running, boot-persistent, scheduled
weekly scan (next run), definitions fresh (DB file mtimes — freshclam
service is active and updates every 2h). The signature files' mtimes
are used instead of the freshclam journal because the very first
update necessarily logs `Clamd was NOT notified` (clamd deliberately
starts after the DB exists) and up-to-date checks log nothing — so the
warning sits at the journal tail until the next real update, which is
noise in an evidence screenshot. Optional proof-of-function shot: the
eicar detection (`sudo clamdscan --multiscan --fdpass /tmp/eicar.com` →
`Infected files: 1` — the eicar filename is self-explanatory to
security reviewers; it is the standard test file the Arch wiki links).
`clamconf` dumps the effective config if a reviewer ever asks for more.

Do NOT blindly adopt the wiki's recommended Alert* hardening lines
(AlertEncrypted, AlertEncryptedArchive, AlertEncryptedDoc ...): on this
machine they would flag kopia/sops/age-encrypted backups as detections
and fail every weekly scan. Defaults keep encrypted files out of the
detection set.

## Weekly system update (Drata "auto-update")

Arch has NO supported unattended-upgrade mechanism (unlike Debian's
unattended-upgrades) — the Drata toggle presumes Windows/macOS
semantics. The honest implementation of the control's intent (patch
currency + evidence): `unattended-update.timer` — weekly Sun 18:00,
AC-only, after the network, deliberately BEFORE the 20:00 AV scan so
the freshly updated system is scanned the same evening. The script
(`/usr/local/sbin/unattended-update`) gates on `checkupdates`
(pacman-contrib), prints the pending list to the journal (the audit
evidence), refreshes the keyring FIRST (classic breakage prevention),
runs the full upgrade, and toasts the outcome with a `.pacnew` count
(the pacdiff duty) and a post-run **failed-units smoke check**
(`systemctl --failed` → the toast goes critical if anything's down).
AUR/yay is deliberately NOT auto-updated —
unattended PKGBUILD execution is a code-execution risk. Unattended
Arch upgrades still carry real risk (news-level interventions won't
be read) — failure toasts + journal transcript; the real safety net
would be btrfs snapshots (backlog).

Install:

    sudo install -m 755 \
      ~/.local/share/chezmoi/.root/usr/local/sbin/unattended-update \
      /usr/local/sbin/unattended-update
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/unattended-update.service \
      /etc/systemd/system/unattended-update.service
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/systemd/system/unattended-update.timer \
      /etc/systemd/system/unattended-update.timer
    sudo systemctl daemon-reload
    sudo systemctl enable --now unattended-update.timer

Verify + immediate Drata evidence: run the job once by hand
(`sudo systemctl start unattended-update` — journal + toast), then
screenshot `proof-updates` (chezmoi-managed): timer enabled + next
fire, last run's journal, pending count now.

## Snapshots (btrfs rollback safety net)

`unattended-update` made update-breakage a weekly possibility worth
insuring. snapper (0.13.2) + snap-pac (3.0.1), both official packages,
all supported mechanisms. snap-pac hooks pacman so EVERY transaction
(install/upgrade/remove) gets an automatic pre + post snapshot pair of
@ (config "root"); the pre hook is AbortOnFail — if the snapshot can't
be taken, the transaction aborts rather than run uninsurable. Hourly
count cleanup via snapper-cleanup.timer: 20 regular / 10 important
pairs; kernel-update pairs tagged important (snap-pac.ini).

Deliberate, with named costs:
- timeline snapshots OFF (TIMELINE_CREATE=no) — pacman pre/post is the
  change vector on this machine (chezmoi owns configs, kopia owns
  home). Cost: no point-in-time recovery for non-pacman changes to /.
- snapper-boot.timer NOT enabled — reboot-sparse workflow; boot
  snapshots would add noise; pacman transactions are the covered risk.
- qgroups OFF — count-based cleanup only (SPACE_LIMIT/FREE_LIMIT
  inert). Cost: no byte-level space guard; irrelevant at 894G free
  (CoW pairs ≈ that day's changed blocks).
- @home NOT snapshotted — kopia's domain.

Managed files (full-file: edit repo → install → verify):
- /etc/snapper/configs/root — base = snapper 0.13.2 shipped template;
  deltas: NUMBER_LIMIT 50→20, TIMELINE_CREATE yes→no
- /etc/snap-pac.ini — stock + one appended [root] section:
  important_packages = ["linux"]

Install:

    sudo snapper -c root create-config /
    sudo install -m 600 \
      ~/.local/share/chezmoi/.root/etc/snapper/configs/root \
      /etc/snapper/configs/root
    sudo install -m 644 \
      ~/.local/share/chezmoi/.root/etc/snap-pac.ini \
      /etc/snap-pac.ini
    sudo systemctl enable --now snapper-cleanup.timer

Verify:

    sudo snapper list-configs                       # root -> /
    sudo snapper -c root get-config | grep -E 'TIMELINE_CREATE|NUMBER_LIMIT'
    ls -l /etc/snapper/configs/root                 # 600 root:root
    systemctl list-timers --no-pager snapper-cleanup.timer
    # the next pacman transaction proves the hooks (pacman.log):
    grep -i snap-pac /var/log/pacman.log | tail -4
    sudo snapper list                               # pairs appear per transaction

Rollback test — the proof, ONCE, at the desk (one reboot):

    sudo snapper create -d rollback-test     # prints the number N
    sudo touch /SNAPSHOT-TEST
    sudo snapper rollback N                  # pre-marker state = new default
    # reboot
    ls /SNAPSHOT-TEST                       # gone -> rollback proven
    sudo snapper list                        # note test numbers, then:
    sudo snapper delete N <postrollback numbers the rollback created>
    # (manual snapshots carry no cleanup algorithm — they stay until
    #  explicitly deleted)

Honest scoping:
- `snapper rollback` needs a BOOTABLE system — systemd-boot has no
  snapshot boot menu (grub-btrfs is grub-only). Unbootable = the
  Phase-3 ISO + subvol-swap break-glass card.
- The ESP (separate vfat partition) is OUTSIDE the snapshot domain:
  kernel/initramfs updates land there. Rolling back @ after a kernel
  update can pair old /usr/lib/modules with a new vmlinuz — rescue =
  ISO chroot + matching kernel reinstall (linux-lts as a standing
  second kernel is the cheap future fix).
- Snapshots age out by count (~5 weekly cycles); the deeper past is
  kopia + the ISO path.

Undo:

    sudo systemctl disable --now snapper-cleanup.timer
    sudo snapper -c root delete-config     # removes /.snapshots + config
    sudo pacman -R snap-pac snapper        # optional; restores stock ini

Undo: `sudo systemctl disable --now clamav-freshclam clamav-daemon
clamav-scan.timer` and remove the ExcludePath block (all three clam*
.conf files are in clamav's backup array — local edits survive package
upgrades as pacnew; compare after major clamav bumps).

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