# Dotfiles Repository (chezmoi)

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/) targeting **Arch Linux (omarchy)** and **macOS**.

## Chezmoi Conventions

- **Naming**: Files use chezmoi prefixes — `dot_` (dotfiles), `private_dot_` (private dirs), `run_once_`/`run_onchange_` (scripts), `.tmpl` (Go templates).
- **Templates**: `.tmpl` files use Go text/template syntax with `{{ .chezmoi.os }}`, `{{ .profile }}` (`personal`/`work`), and `{{ .email }}` as the main data variables (see `.chezmoi.yaml.tmpl`).
- **External deps**: Managed in `.chezmoiexternal.yaml` (currently: tmux TPM).
- **Ignored paths**: See `.chezmoiignore` — `scripts/` dir is NOT applied by chezmoi (it's manual-run tooling).
- Apply changes: `chezmoi apply`. Preview: `chezmoi diff`. Add file: `chezmoi add <path>`.

## Repository Layout

```
.
├── private_dot_config/       -> ~/.config/
│   ├── ghostty/              # Ghostty terminal config
│   ├── helix/                # Helix editor
│   ├── k9s/                  # Kubernetes TUI (catppuccin latte skin)
│   ├── kanata/               # Keyboard remapper (home-row mods)
│   ├── lazygit/              # Lazygit
│   ├── nvim/                 # Neovim (LazyVim-based)
│   ├── starship.toml         # Starship prompt (catppuccin latte)
│   ├── systemd/user/         # User systemd services (kanata)
│   └── wezterm/              # WezTerm terminal (light themes)
├── scripts/                  # Manual setup scripts (not chezmoi-managed)
├── dot_zshrc.tmpl            # Main ZSH config (antidote, vi-mode, deferred loads)
├── dot_gitconfig.tmpl        # Git config (delta pager, GPG signing)
├── dot_tmux.conf             # Tmux (C-Space prefix, catppuccin, tilish)
├── dot_zsh_plugins.txt       # Antidote plugin list
├── run_once_100_*            # macOS: brew bundle
├── run_once_103_*            # ZSH antidote bootstrap
├── run_once_200_*            # Neovim packer setup
├── run_once_201_*            # FZF ZSH integration
└── run_onchange_install-*    # Arch: pacman + AUR package installation
```

## Key Design Decisions

- **Theme**: Catppuccin Latte (light theme) throughout — starship, tmux, k9s, wezterm, nvim.
- **Shell**: ZSH with antidote plugin manager. Startup optimized for <100ms (cached starship init, deferred evals for atuin/zoxide/kubesess, hardcoded brew prefix).
- **Keyboard**: Kanata home-row mods (a/s/d/f = ctrl/alt/meta/shift, mirrored on j/k/l/;). Excludes splitkb Kyria.
- **Editor**: Neovim via LazyVim distribution.
- **Terminal**: Ghostty (default), WezTerm also configured.
- **Tmux prefix**: `C-Space`. Uses tilish for tiling, TPM for plugins.
- **Git**: GPG-signed commits, delta as pager, ghq for repo management (`~/git` personal, `~/repos` work).
- **Packages**: Arch packages via pacman + yay/paru AUR helper. macOS via Homebrew.
- **Profiles**: `personal` vs `work` — affects SSH agent (rbw), git URLs (HTTPS rewrite for work), ghq root.

## Script Standards

Scripts in `scripts/` should be:
- Idempotent (safe to re-run)
- Use `set -euo pipefail`
- Provide colored status messages
- Handle sudo requirements explicitly

## Editing Guidelines

- When modifying `.tmpl` files, preserve Go template syntax and conditionals.
- Test template rendering with `chezmoi cat <target-path>` to verify output.
- Package additions go in `run_onchange_install-packages.sh.tmpl` (Arch) or `run_once_100_install-brews.sh.tmpl` (macOS).
- New config dirs under `private_dot_config/` should use chezmoi naming conventions.
