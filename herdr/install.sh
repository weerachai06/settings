#!/usr/bin/env bash
set -e
export PATH="$HOME/.local/bin:$PATH"

if ! command -v herdr >/dev/null; then
  echo "==> install herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
fi

echo "==> install agent integrations (kiro has none)"
for tool in claude opencode; do
  if herdr integration status | grep -q "^$tool: current"; then
    echo "    $tool: current"
  else
    herdr integration install "$tool"
  fi
done

echo "==> write herdr skill from the installed binary"
for tool_dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.kiro/skills"; do
  mkdir -p "$tool_dir/herdr"
  herdr --skill > "$tool_dir/herdr/SKILL.md"
done
