# Dotfiles Repository Context

This is a dotfiles repository managed by **chezmoi** for configuring an Arch Linux system (omarchy distribution).

## Repository Structure

- `private_dot_config/` - Configuration files managed by chezmoi (applied to `~/.config/`)
  - `helix/` - Helix editor configuration
  - `k9s/` - Kubernetes CLI configuration
  - `kanata/` - Kanata keyboard remapper configuration
  - `lazygit/` - Lazygit configuration
  - `nvim/` - Neovim configuration
  - `wezterm/` - WezTerm terminal configuration
- `scripts/` - Setup and automation scripts (not necessarily applied by chezmoi)
  - `setup-kanata.sh` - Automated Kanata Linux setup script

## Working with Setup Scripts

Setup scripts in `scripts/` are meant to automate system configuration tasks that don't fit into the typical chezmoi workflow. These scripts:

- Should be idempotent (safe to run multiple times)
- Should provide clear status messages and warnings
- Should handle errors gracefully with `set -euo pipefail`
- Should be executable (`chmod +x`)
- May require sudo/root privileges for system configuration

### Example: Kanata Setup Script

The `setup-kanata.sh` script automates the Linux setup for Kanata keyboard remapper:
- Creates system groups and adds user to them
- Configures udev rules
- Loads kernel modules
- Creates and enables systemd user service

Run with: `sudo ./scripts/setup-kanata.sh`

## Chezmoi Commands

Common chezmoi commands:
- `chezmoi apply` - Apply configuration changes to the system
- `chezmoi edit <file>` - Edit a managed file
- `chezmoi add <file>` - Add a new file to be managed
- `chezmoi diff` - See what would change

## Notes

- This is an active setup for a new laptop migration
- Configuration is tailored for Arch Linux (omarchy)
- Group membership changes require logout/login to take effect
