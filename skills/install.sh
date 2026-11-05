#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> symlink local skills to tools"
for tool_dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.kiro/skills"; do
  mkdir -p "$tool_dir"
  for skill_dir in "$DOTFILES/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    rm -rf "$tool_dir/$skill_name"
    ln -s "${skill_dir%/}" "$tool_dir/$skill_name"
  done
done
