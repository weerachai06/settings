#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$DOTFILES/lib.sh"

install() {
  echo "Installing dotfiles..."

  for dir in homebrew zsh git wezterm zed global-protect opencode claude gh-pr-notifier instructions skills; do
    script="$DOTFILES/$dir/install.sh"
    if [ -f "$script" ]; then
      bash "$script"
    fi
  done

  echo "Done."
}

prune() {
  echo "Pruning dotfiles symlinks..."

  for dst in \
    "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile" \
    "$HOME/.gitconfig" "$HOME/.gitignore_global" \
    "$HOME/.config/wezterm/wezterm.lua" \
    "$HOME/.config/zed/settings.json" "$HOME/.config/zed/keymap.json" "$HOME/.config/zed/tasks.json" \
    "$HOME/global-protect.sh" \
    "$HOME/.config/opencode/opencode.jsonc" "$HOME/.opencode/AGENTS.md" \
    "$HOME/.config/opencode/skills" \
    "$HOME/.claude/settings.json" "$HOME/.claude/CLAUDE.md" "$HOME/.claude/skills"
  do
    unlink_path "$dst"
  done

  echo "Done."
}

case "${1:-install}" in
  install) install ;;
  prune)   prune ;;
  *)       echo "Usage: $0 [install|prune]"; exit 1 ;;
esac
