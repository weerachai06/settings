#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/lib.sh"

LOCAL="$(dirname "$0")/.local"
if [ -f "$LOCAL" ]; then
  set -a
  # shellcheck source=homebrew/.local
  source "$LOCAL"
  set +a
fi

echo "==> Homebrew packages"
brew bundle --no-lock --file="$(dirname "$0")/Brewfile"
