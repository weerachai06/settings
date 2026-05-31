#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/lib.sh"

echo "==> Homebrew packages"
brew bundle --no-lock --file="$(dirname "$0")/Brewfile"
