#!/usr/bin/env bash
set -e

SKILLS_SRC="$(cd "$(dirname "$0")" && pwd)"

DESTINATIONS=(
  "$HOME/.claude/skills"
  "$HOME/.config/opencode/skills"
)

link_skill() {
  local name="$1"
  local src="$SKILLS_SRC/$name"

  for dst_dir in "${DESTINATIONS[@]}"; do
    local dst="$dst_dir/$name"
    mkdir -p "$dst_dir"
    if [ -L "$dst" ]; then
      echo "  skip (already linked): $dst_dir/$name"
    elif [ -e "$dst" ]; then
      echo "  warn (exists, not a symlink): $dst — skipping"
    else
      ln -s "$src" "$dst"
      echo "  linked: $dst"
    fi
  done
}

if [ -n "$1" ]; then
  link_skill "$1"
else
  for dir in "$SKILLS_SRC"/*/; do
    name="$(basename "$dir")"
    link_skill "$name"
  done
fi
