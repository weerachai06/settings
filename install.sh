#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -m)" in
  x86_64)  NIX_SYSTEM="x86_64-linux" ;;
  aarch64) NIX_SYSTEM="aarch64-linux" ;;
  *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
esac

# home.nix expects ~/.dotfiles to be the repo root (for mkOutOfStoreSymlink paths)
if [ ! -e "$HOME/.dotfiles" ]; then
  ln -sf "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Enable flakes + nix-command (required for home-manager)
mkdir -p "$HOME/.config/nix"
echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"

echo "Activating home-manager config for $NIX_SYSTEM (user: $USER)..."
nix run nixpkgs#home-manager -- switch \
  --flake "${DOTFILES_DIR}#${NIX_SYSTEM}" \
  --impure

# home-manager installs its own binary here; put it on PATH for the rest of this shell
export PATH="$HOME/.nix-profile/bin:$PATH"
