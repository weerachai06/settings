#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect Linux arch
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  NIX_SYSTEM="x86_64-linux" ;;
  aarch64) NIX_SYSTEM="aarch64-linux" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# home.nix expects ~/.dotfiles to be the repo root (for mkOutOfStoreSymlink paths)
if [ ! -e "$HOME/.dotfiles" ]; then
  ln -sf "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Install Nix (single-user, no daemon — works in containers)
if ! command -v nix &>/dev/null; then
  echo "Installing Nix (single-user)..."
  curl -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
fi
# shellcheck disable=SC1091
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

echo "Activating home-manager config for $NIX_SYSTEM (user: $USER)..."
nix run home-manager/master -- switch \
  --flake "${DOTFILES_DIR}#${NIX_SYSTEM}" \
  --impure
