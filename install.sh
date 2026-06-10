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

# Install Nix via Determinate Systems installer if not present
if ! command -v nix &>/dev/null; then
  echo "Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Ensure nix-daemon is running (multi-user install requires it)
if command -v systemctl &>/dev/null; then
  sudo systemctl start nix-daemon 2>/dev/null || true
elif [ -e /nix/var/nix/profiles/default/bin/nix-daemon ]; then
  sudo /nix/var/nix/profiles/default/bin/nix-daemon &
  sleep 2
fi

echo "Activating home-manager config for $NIX_SYSTEM (user: $USER)..."
nix run home-manager/master -- switch \
  --flake "${DOTFILES_DIR}#${NIX_SYSTEM}" \
  --impure
