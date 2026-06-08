#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> skills"
npx --yes skills@latest add mattpocock/skills --global --all
npx --yes skills@latest add vercel-labs/agent-skills --skill vercel-react-best-practices --global --yes

rm -f "$HOME/.agents/skills/skills"

echo "==> custom skills (claude + opencode)"
mkdir -p "$HOME/.agents/skills"
for skill_dir in "$DOTFILES/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  ln -sf "$skill_dir" "$HOME/.agents/skills/$skill_name"
done
