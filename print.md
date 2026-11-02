# Printing & scanning — Brother MFC-L8690CDW

Network color laser MFC on the LAN. **Driverless end to end** — no Brother
drivers, no PPDs, no AUR scanner packages. Both protocols were probe-confirmed
before installing anything (IPP: `GET /ipp/print` → 405, i.e. alive; scan:
`/eSCL/ScannerCapabilities` → real capability XML, plus WSD endpoints via
`airscan-discover`).

## Addressing (the one quirk)

The router's DNS serves **flat names** but never registers `.lan` FQDNs:
`Brother-L8690CDW-ClemJul` resolves (→ 192.168.63.30), `….lan` does not.
avahi/mDNS stays off by design. CUPS uses the flat name; the scanner entry
pins the IPv4 (see below). If the flat name ever flakes after a router
reboot: `/etc/hosts` pin, or — better — a DHCP reservation for `.30` on
the router, which makes both addressing styles eternal.

## Print setup (fresh machine, in order)

1. Packages: `cups ghostscript gsfonts` (in the packages script).
   **The ghostscript trap**: it's an *optional* dependency of cups-filters;
   without it every rasterized job dies with `gstoraster filter failed`
   (hit on the first test page, 2026-11-02). Failed jobs **park in the
   queue** — `cancel MFC-L8690CDW-<id>` before reprinting.
2. `sudo systemctl enable --now cups.socket` — socket activation; cupsd
   is not resident until something actually prints.
3. Queue, driverless:

       sudo lpadmin -p MFC-L8690CDW -E \
         -v "ipp://Brother-L8690CDW-ClemJul/ipp/print" -m everywhere

   — the `everywhere` model pulls the printer's own capability sheet
   (A4, both trays, duplex, color — all data, nothing installed).
4. Default queue: `sudo lpoptions -d MFC-L8690CDW` (system-wide, in use)
   or plain `lpoptions -d …` (per-user → `~/.lpoptions`).
5. Test: `lp -d MFC-L8690CDW /usr/share/cups/data/default-testpage.pdf`.

## CUPS admin — there are no cupsd accounts

The web UI (http://localhost:631) login is PAM-checked against `SystemGroup`;
on Arch the compiled default accepts **wheel** — verified live, no config
edits needed: login = cjmnuss + the login password. The CLI never prompts:
local clients authenticate by domain-socket peer credentials, which is why
`sudo lpadmin` suffices.

## Scanning

**Primary workflow: scan-to-FTP from the printer** — press scan on the
MFC, it pushes the file to the FTP destination (configured on the
printer's web console; nothing on this machine to manage). No PC-side
scanner stack is involved in that flow at all.

The PC-side stack (sane-airscan + simple-scan) is the *optional*
pull-scan path for the rare "scan straight into the machine" case — and
it works **zero-config**: airscan's built-in WS-Discovery finds the
printer per-invocation (no avahi, no daemon; proven by a live test scan).
No `/etc/sane.d/airscan.conf` entry is installed. Two facts for the day
that needs to change:

- **airscan ignores `~/.config/sane.d/`** — only `/etc/sane.d/airscan.conf`
  counts (root-side). That file is also package-owned and NOT in the
  package's backup array, so a sane-airscan upgrade silently overwrites
  local edits.
- If WS-Discovery ever stops finding the scanner (VLAN/IGMP changes),
  install the pinned entry archived in `.root/etc/sane.d/airscan.conf`
  (`.root/README.md` has the line) — the WSD endpoint the printer itself
  advertises, pinned to IPv4:

      [devices]
        Brother MFC-L8690CDW = http://192.168.63.30:80/WebServices/ScannerService, WSD

Verify any time: `scanimage -L`; UI: `simple-scan` from the launcher
(flatbed + ADF both exposed).

## Root-side pieces

`.root/README.md` carries the install/undo blocks: `cups.socket` enable,
the `lpadmin`/`lpoptions` lines, and the airscan entry install.