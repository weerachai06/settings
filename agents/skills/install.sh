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

echo "==> symlink Claude Code mods"
mkdir -p "$HOME/.claude/skills"
for mod_dir in "$DOTFILES/mods"/*/; do
  mod_name="$(basename "$mod_dir")"
  rm -rf "$HOME/.claude/skills/$mod_name"
  ln -s "${mod_dir%/}" "$HOME/.claude/skills/$mod_name"
done

echo "==> symlink subagents to Kiro and OpenCode"
for pair in "kiro/agents:$HOME/.kiro/agents" "opencode/agents:$HOME/.config/opencode/agents"; do
  src="$DOTFILES/${pair%%:*}"
  dest="${pair#*:}"
  mkdir -p "$dest"
  for agent_file in "$src"/*; do
    rm -f "$dest/$(basename "$agent_file")"
    ln -s "$agent_file" "$dest/$(basename "$agent_file")"
  done
done
