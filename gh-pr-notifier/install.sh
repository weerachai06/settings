#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> gh-pr-notifier"
brew_install gh
if cmd_installed python3; then
  echo "  skip: python3 (already installed)"
else
  brew install python3
fi

if cmd_installed gh && ! gh auth status &>/dev/null 2>&1; then
  echo "  note: gh not authenticated — run: gh auth login"
fi
