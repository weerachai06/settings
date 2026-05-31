#!/usr/bin/env bash
set -e

DOTFILES="$HOME/.dotfiles"

link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "  backed up: $dst -> $dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "  linked: $dst -> $src"
}

echo "Installing dotfiles..."

# Zsh
link "$DOTFILES/zsh/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"  "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

# Git
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# WezTerm
link "$DOTFILES/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Zed
link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"
link "$DOTFILES/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

echo "Done."
