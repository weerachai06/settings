#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS + arch → Nix system double
OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS-$ARCH" in
  Darwin-arm64)  NIX_SYSTEM="aarch64-darwin" ;;
  Darwin-x86_64) NIX_SYSTEM="x86_64-darwin" ;;
  Linux-x86_64)  NIX_SYSTEM="x86_64-linux" ;;
  Linux-aarch64) NIX_SYSTEM="aarch64-linux" ;;
  *) echo "Unsupported platform: $OS-$ARCH"; exit 1 ;;
esac

# home.nix expects ~/.dotfiles to be the repo root (for mkOutOfStoreSymlink paths)
if [ ! -e "$HOME/.dotfiles" ]; then
  ln -sf "$DOTFILES_DIR" "$HOME/.dotfiles"
fi

# Install Nix if not present.
# macOS requires a multi-user (daemon) install; Linux/containers use single-user.
if ! command -v nix &>/dev/null && [ ! -e /nix/store ]; then
  if [ "$OS" = "Darwin" ]; then
    echo "Installing Nix (multi-user, daemon)..."
    curl -sSfL https://nixos.org/nix/install | sh -s -- --daemon
  else
    echo "Installing Nix (single-user)..."
    curl -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
  fi
fi

# Source Nix — path differs between single-user and multi-user installs
# shellcheck disable=SC1091
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # Linux multi-user installs need the daemon started manually (macOS uses launchd)
  if [ "$OS" = "Linux" ] && ! nix store ping &>/dev/null; then
    sudo /nix/var/nix/profiles/default/bin/nix-daemon &
    sleep 3
  fi
else
  echo "error: Nix profile not found"; exit 1
fi

# Enable flakes + nix-command (required for home-manager)
mkdir -p "$HOME/.config/nix"
echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"

echo "Activating home-manager config for $NIX_SYSTEM (user: $USER)..."
nix run home-manager/master -- switch \
  --flake "${DOTFILES_DIR}#${NIX_SYSTEM}" \
  --impure
