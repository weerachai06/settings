#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> skills"
npx --yes skills@latest add mattpocock/skills --global --all
npx --yes skills@latest add vercel-labs/agent-skills --skill vercel-react-best-practices --global --yes

rm -f "$HOME/.agents/skills/skills"

echo "==> custom skills"
mkdir -p "$HOME/.agents/skills"
for skill_dir in "$DOTFILES/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  ln -sf "$skill_dir" "$HOME/.agents/skills/$skill_name"
done

echo "==> link skills to agents"
SKILLS=(
  caveman
  design-an-interface
  diagnose
  edit-article
  find-skills
  git-guardrails-claude-code
  grill-me
  grill-with-docs
  handoff
  improve-codebase-architecture
  migrate-to-shoehorn
  obsidian-vault
  pr-reviewer
  pr-with-target-branch
  prototype
  qa
  request-refactor-plan
  review
  scaffold-exercises
  setup-pre-commit
  tdd
  teach
  to-issues
  to-prd
  triage
  ubiquitous-language
  vercel-react-best-practices
  web-design-guidelines
  wiki-docs
  write-a-skill
  writing-beats
  writing-fragments
  writing-shape
  zoom-out
)

for tool_dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
  mkdir -p "$tool_dir"
  for skill in "${SKILLS[@]}"; do
    ln -sf "$HOME/.agents/skills/$skill" "$tool_dir/$skill"
  done
done
