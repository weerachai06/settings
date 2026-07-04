#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# home.nix expects ~/.dotfiles to be the repo root (for mkOutOfStoreSymlink paths)
if [ ! -e "$HOME/.dotfiles" ]; then
  ln -sf "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Enable flakes + nix-command (required for home-manager)
mkdir -p "$HOME/.config/nix"
echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"

echo "Activating home-manager config for x86_64-linux (user: $USER)..."
nix run home-manager/master -- switch \
  --flake "${DOTFILES_DIR}#x86_64-linux" \
  --impure
