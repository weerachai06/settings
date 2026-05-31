#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../lib.sh
source "$DOTFILES/lib.sh"

echo "==> zsh"
brew_install zsh-autosuggestions
brew_install zsh-syntax-highlighting
brew_install openssl@3

link "$DOTFILES/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES/zsh/.zshenv"   "$HOME/.zshenv"
link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"
