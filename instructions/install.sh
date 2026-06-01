#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> instructions"
mkdir -p "$HOME/instructions"
for f in "$DOTFILES/instructions/"*.md; do
  link "$f" "$HOME/instructions/$(basename "$f")"
done
