#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> opencode"
link "$DOTFILES/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
link "$DOTFILES/opencode/AGENTS.md"      "$HOME/.opencode/AGENTS.md"
link "$HOME/.agents/skills"              "$HOME/.config/opencode/skills"
"$DOTFILES/skills/sync-skills.sh"
