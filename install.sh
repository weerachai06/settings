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

# Install Nix if not present (single-user, no daemon — works in containers)
if ! command -v nix &>/dev/null && [ ! -e /nix/store ]; then
  echo "Installing Nix (single-user)..."
  curl -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
fi

# Source Nix — path differs between single-user and multi-user installs
# shellcheck disable=SC1091
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # Multi-user install needs daemon running
  if ! nix store ping &>/dev/null; then
    sudo /nix/var/nix/profiles/default/bin/nix-daemon &
    sleep 3
  fi
else
  echo "error: Nix profile not found"; exit 1
fi

echo "Activating home-manager config for $NIX_SYSTEM (user: $USER)..."
nix run home-manager/master -- switch \
  --flake "${DOTFILES_DIR}#${NIX_SYSTEM}" \
  --impure
