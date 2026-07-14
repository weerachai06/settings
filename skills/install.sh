#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh

echo "==> skills (via npx)"
npx --yes skills@latest add mattpocock/skills --global --all
npx --yes skills@latest add vercel-labs/agent-skills --skill vercel-react-best-practices --global --yes

rm -f "$HOME/.agents/skills/skills"
# skills@latest creates a circular symlink <name>/<name> inside each skill dir
for _skill_dir in "$HOME/.agents/skills"/*/; do
  _skill_name="$(basename "$_skill_dir")"
  rm -f "$_skill_dir/$_skill_name"
done

echo "==> copy custom skills to .agents"
mkdir -p "$HOME/.agents/skills"
for skill_dir in "$DOTFILES/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  # Remove old symlink if it exists
  rm -f "$HOME/.agents/skills/$skill_name"
  # Copy instead of symlink to avoid circular references
  cp -r "$skill_dir" "$HOME/.agents/skills/$skill_name"
done

echo "==> symlink skills to tools"
SKILLS=(
  ast-grep
  ast-grep-outline
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
