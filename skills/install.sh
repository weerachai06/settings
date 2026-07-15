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
  # Remove old symlink or directory if it exists
  rm -rf "$HOME/.agents/skills/$skill_name"
  # Copy instead of symlink to avoid circular references
  cp -r "$skill_dir" "$HOME/.agents/skills/$skill_name"
done

echo "==> symlink skills to tools"
SKILLS=(
  ast-grep
  ast-grep-outline
  design-an-interface
  diagnosing-bugs
  edit-article
  git-guardrails-claude-code
  grill-me
  grill-with-docs
  handoff
  improve-codebase-architecture
  migrate-to-shoehorn
  obsidian-vault
  pr-with-target-branch
  prototype
  qa
  request-refactor-plan
  scaffold-exercises
  setup-pre-commit
  tdd
  teach
  to-tickets
  to-spec
  triage
  ubiquitous-language
  vercel-react-best-practices
  wiki-docs
  writing-great-skills
  writing-beats
  writing-fragments
  writing-shape
)

for tool_dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.kiro/skills"; do
  # Replace old whole-directory symlinks (previously pointed at ~/.agents/skills)
  # with a real directory, otherwise rm -rf below deletes through the symlink.
  [ -L "$tool_dir" ] && rm -f "$tool_dir"
  mkdir -p "$tool_dir"
  for skill in "${SKILLS[@]}"; do
    rm -rf "$tool_dir/$skill"
    cp -r "$HOME/.agents/skills/$skill" "$tool_dir/$skill"
  done
done
