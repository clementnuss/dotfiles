# GPG — master key maintenance

Key `05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9` (rsa4096, 2022-08-29, no expiry).
The **primary (master) secret lives offline**; the daily keyring (`~/.gnupg`)
holds only a stub of it (`sec#`) plus the signing subkey — the key every
commit is signed with, personal and work alike.

## Current state (2026-11-05)

| Part | State |
|---|---|
| UID `clement@n8r.ch` | **primary UID** |
| UID `clement@astutus.org` | valid |
| UID `clement@victoriametrics.com` | valid (added 2026-11-05) — VictoriaMetrics commits |
| UID `clement.nussbaumer@postfinance.ch` | **revoked** 2026-11-05 ("Left PostFinance") |
| subkey `4896B4066D82D23D99728E2BBD59E0A0BD89E70D` ed25519 [S] | **the signing key**, expires **2027-10-16** |
| subkey `F18F3A24AE3695FBADB316EFEF6080104246AD5D` rsa4096 [E] | **revoked** 2026-11-05 — secret lost |
| subkeys `889F…`, `80B2…` (+ `A643…`, `5242…` on keys.openpgp.org) | expired, harmless |

No encryption subkey exists — nothing encrypted to me can be read. Add one
only if needed: `gpg --quick-add-key "$FPR" cv25519 encr 2y` (master session).

**Backups**
- **Master backup 2026-11-05** (`.asc`, offline): primary + `BD59…` secrets,
  complete. Passphrase in **Bitwarden** (set with `gpg --passwd` that day,
  verified by re-import). This is the one to use.
- Older "GPG-2025-full" master export: **unreadable** — passphrase unknown,
  retire it. A non-"full" file from the same era is a *subkeys-only* export
  (`sec#`) — useless for master operations.
- The daily `~/.gnupg` copy of `BD59…` kept its own (older) passphrase;
  `gpg --passwd BD59E0A0BD89E70D` aligns it if ever wanted.
- **No revocation certificate exists yet** — see backlog.

Published at: GitHub (`github.com/clementnuss.gpg`), keyserver.ubuntu.com,
keys.openpgp.org (UIDs listed only once their email is verified there).

## Mental model

```
primary key ──┬── UID clement@n8r.ch       ← 0x13 selfsig (primary certifies the UID)
              ├── UID …                    ← 0x13
              └── subkey BD59…             ← 0x18 binding sig (primary certifies the subkey)
```

- **Emails live in UIDs, never in subkeys.** Any subkey signs for the whole key;
  GitHub maps the signing subkey → primary → looks for a UID matching the
  committer email (which must also be a verified email on the account).
- Anything that changes UIDs, subkeys or expiry = a new signature *by the
  primary* → needs the offline master. Signing commits never does.
- **The primary is the identity** (fingerprint = hash of its public key): it
  can't be rotated, only replaced by a new key (cross-certify, publish, later
  revoke the old one as "superseded"). Subkeys rotate freely.
- **The master's secret never changes** — only the passphrase wrapping it in a
  given export. *Any* backup copy you can open is the master, however old: all
  UIDs, selfsigs and subkey bindings are **public** packets, merged back in from
  the daily keyring (session step 2). Nothing in a newer backup is lost by
  using an older one.
- **Revoke, don't delete.** Deleting a UID/subkey is local-only (every existing
  copy keeps it, keyservers never forget). A revocation is a signed,
  timestamped (`sig created` is hashed, unforgeable) packet that travels with
  the key; the original selfsig stays, so history reads "certified 2022,
  revoked 2026". Not retroactive: old signatures still verify.
- `[?]`/`[ unknown]` validity on my own UIDs = no ownertrust set in this
  keyring. Cosmetic; GitHub doesn't care.
- `.asc` (`--armor`) vs `.gpg` (binary): same packets. Armor is greppable —
  the header says `PRIVATE KEY BLOCK` vs `PUBLIC KEY BLOCK`.

## Telling backup files apart (no passphrase needed)

```sh
gpg --list-packets FILE | grep -E '^:secret|keyid:|protected|gnu-dummy'
```

`skey[…]: [v4 protected]` on the `A99C6A4E3C856DA9` packet = real master;
`gnu-dummy` = stub. **Don't trust `gpg --show-keys`** here: it prints `sec#`
even for real secret exports. After importing, `gpg -K` is authoritative:
`sec` = master present, `sec#` = stub.

## Master session

Do everything in **one dedicated terminal** and close it at the end: the
exported `GNUPGHOME` points that shell's `gpg` at the throwaway keyring.

### 1. Throwaway keyring on tmpfs

```sh
export GNUPGHOME=$(mktemp -d -p "$XDG_RUNTIME_DIR" gpg-master.XXXXXX)   # tmpfs, mode 0700
FPR=05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9
MASTER=/path/to/master-backup.asc
```

### 2. Import the master + the current public state

```sh
gpg --import "$MASTER"          # pinentry asks the backup's passphrase (Bitwarden)
gpg --homedir ~/.gnupg --export "$FPR" | gpg --import
gpg -K --keyid-format long "$FPR"
```

✅ First line `sec`, **not** `sec#`. `Bad passphrase` on import = wrong
passphrase for that file (the import decrypts to hand the key to the agent);
`Operation cancelled` = pinentry closed, nothing tested. Retries are free.

**Backup is a whole `.gnupg` directory** (e.g. from Time Machine) instead of an
export? The secret is one file, `private-keys-v1.d/<keygrip>.key`:

```sh
gpg --homedir ~/.gnupg --with-keygrip -k "$FPR" | grep -m1 Keygrip   # the primary's keygrip
mkdir -p -m 700 "$GNUPGHOME/private-keys-v1.d"
cp /path/to/old/.gnupg/private-keys-v1.d/<KEYGRIP>.key "$GNUPGHOME/private-keys-v1.d/"
gpg -K "$FPR"                                                        # stub → sec
```

### 3. Make the changes

Pick what the session is for:

```sh
# add a UID
gpg --quick-add-uid "$FPR" 'Clément Nussbaumer <new@example.com>'
# extend the signing subkey (keeps the same subkey — no git config change)
gpg --quick-set-expire "$FPR" 2y 4896B4066D82D23D99728E2BBD59E0A0BD89E70D
```

⚠️ A new UID can steal the primary-UID slot. Check the `.` marker in `list`;
fix with `gpg --quick-set-primary-uid "$FPR" 'Clément Nussbaumer <clement@n8r.ch>'`
— it fails with `General error` when that UID already *is* primary (harmless).

**Revocations with a comment** are interactive (`--quick-revoke-uid` can't add
one):

```sh
gpg --edit-key "$FPR"
```

```
gpg> list              # numbers are NOT creation order — read them
gpg> uid N             # select a UID → * appears; check it's the only one
gpg> revuid            # y → 4 "User ID is no longer valid" → comment → empty line → y
gpg> uid 0             # deselect all UIDs
gpg> key M             # select a subkey (ssb/sub lines counted from 1) → check the *
gpg> revkey            # y → 3 "Key is no longer used" (1 = compromised, 2 = superseded)
gpg> save              # ⚠️ nothing is written until save; quit discards
```

### 4. Check

```sh
gpg -k --list-options show-unusable-uids,show-unusable-subkeys "$FPR"
```

### 5. Passphrase you will find again

```sh
gpg --passwd "$FPR"     # → store in Bitwarden NOW
```

"No secret key" errors for the expired/revoked subkeys are expected (their
secrets aren't there); the primary and `BD59…` still get the new passphrase.

### 6. Write the new backup (new file, old one untouched) and verify it

```sh
NEW_MASTER="${MASTER%.*}-$(date +%F).asc"
( umask 077; gpg --armor --export-secret-keys "$FPR" > "$NEW_MASTER" )

V=$(mktemp -d -p "$XDG_RUNTIME_DIR" gpg-verify.XXXXXX)
gpg --homedir "$V" --import "$NEW_MASTER" && gpg --homedir "$V" -K
gpgconf --homedir "$V" --kill all; rm -rf "$V"
```

✅ `sec` and `ssb` without `#`, and the import's pinentry accepted the
passphrase **copied from Bitwarden** (`wl-copy -n` or typed — not memory).

### 7. Refresh the daily keyring (public parts only — no secrets move)

```sh
gpg --export "$FPR" | gpg --homedir ~/.gnupg --import
gpg --homedir ~/.gnupg -K "$FPR"
```

✅ Still `sec#` (stub), `BD59…` still `ssb`.

### 8. Tear down

```sh
gpgconf --kill all          # stops the throwaway agent (GNUPGHOME still set)
rm -rf "$GNUPGHOME"
exit                        # close this terminal
```

Move `$NEW_MASTER` offline; delete every backup copy left in `/tmp`.

### 9. Publish (normal terminal, daily keyring)

```sh
# GitHub doesn't refresh keys in place: Settings → SSH and GPG keys → delete, re-add
gpg --armor --export 05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9 | wl-copy

# keyserver.ubuntu.com: merges everything, never deletes (→ why we revoke)
gpg --keyserver hkps://keyserver.ubuntu.com --send-keys 05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9

# keys.openpgp.org: keys/revocations publish at once, UIDs only after email
# verification — open the returned link, "Send verification email" per new UID
gpg --export 05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9 | curl -T - https://keys.openpgp.org
```

Check what a server publishes:
`curl -fsS https://keys.openpgp.org/vks/v1/by-fingerprint/05E5B89D80C25328FA6DC21FA99C6A4E3C856DA9 | gpg --show-keys`
(GitHub: `https://github.com/clementnuss.gpg`).

## Backlog — next master session (at the latest: before 2027-10-16)

- **Extend `BD59…`** (step 3) — it expires 2027-10-16; then re-publish.
- **Revocation certificate** — none exists (`~/.gnupg/openpgp-revocs.d/` is
  absent; the key was made elsewhere in 2022). It revokes the key even if the
  master is lost for good — 2026-11-05 came close:
  `gpg --generate-revocation "$FPR" > revoke-05E5B89D.asc`. Store offline,
  apart from the master backup (or print it). Whoever holds it can revoke the
  key, not sign as me.
- **Expiry on the primary** (dead-man switch): `gpg --quick-set-expire "$FPR" 2y`,
  extended each session — a lost master + lost revocation cert then still
  dies on its own, and the ritual proves yearly that the backup opens.

## History

- **2026-11-05** — added the VictoriaMetrics UID, revoked the PostFinance UID
  and the lost `EF60…` encryption subkey, new passphrase, first *complete*
  master backup, published to GitHub + both keyservers. The "full" 2025 export
  wouldn't open (unknown passphrase); recovered with an older copy — same
  master secret, public state merged from the daily keyring.
