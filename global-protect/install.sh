#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> global-protect"
link "$DOTFILES/global-protect/global-protect.sh" "$HOME/global-protect.sh"
