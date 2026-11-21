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
for tool_dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.kiro/skills" "$HOME/.pi/agent/skills"; do
  mkdir -p "$tool_dir/herdr"
  herdr --skill > "$tool_dir/herdr/SKILL.md"

  # Herdr desktop app: hc (herdr-core) and herdr-app ship manuals without frontmatter
  if command -v herdr-core >/dev/null && command -v herdr-app >/dev/null; then
    mkdir -p "$tool_dir/hc" "$tool_dir/herdr-app"
    {
      printf -- '---\nname: hc\ndescription: "Message, read, wait on and start agents and programs in Herdr desktop app terminals with hc (herdr-core). Use only when the user explicitly mentions Herdr and HC_TERMINAL_ID is set."\n---\n\n'
      herdr-core --skill
    } > "$tool_dir/hc/SKILL.md"
    {
      printf -- '---\nname: herdr-app\ndescription: "Change what the person sees in the Herdr desktop app (spaces, tabs, panes) with herdr-app. Use only when the user explicitly mentions Herdr and HC_TERMINAL_ID is set."\n---\n\n'
      herdr-app --skill
    } > "$tool_dir/herdr-app/SKILL.md"
  fi
done
