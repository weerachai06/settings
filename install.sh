#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

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

unlink() {
  local dst="$1"

  if [ -L "$dst" ]; then
    rm "$dst"
    echo "  removed: $dst"
  fi
}

install() {
  echo "Installing dotfiles..."

  # Zsh
  link "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
  link "$DOTFILES/zsh/.zshenv"   "$HOME/.zshenv"
  link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"

  # Git
  link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

  # WezTerm
  link "$DOTFILES/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

  # Zed
  link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"
  link "$DOTFILES/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

  # GlobalProtect
  link "$DOTFILES/global-protect/global-protect.sh" "$HOME/global-protect.sh"

  echo "Done."
}

prune() {
  echo "Pruning dotfiles symlinks..."

  unlink "$HOME/.zshrc"
  unlink "$HOME/.zshenv"
  unlink "$HOME/.zprofile"
  unlink "$HOME/.gitconfig"
  unlink "$HOME/.config/wezterm/wezterm.lua"
  unlink "$HOME/.config/zed/settings.json"
  unlink "$HOME/.config/zed/keymap.json"
  unlink "$HOME/global-protect.sh"

  echo "Done."
}

case "${1:-install}" in
  install) install ;;
  prune)   prune ;;
  *)       echo "Usage: $0 [install|prune]"; exit 1 ;;
esac
