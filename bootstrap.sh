#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$DOTFILES/lib.sh"

echo
echo "==> Homebrew"
if cmd_installed brew; then
  echo "  skip: brew (already installed)"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo
echo "==> Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  skip: oh-my-zsh (already installed)"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo
echo "==> Rust"
if [ -d "$HOME/.cargo" ]; then
  echo "  skip: rust (already installed)"
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

echo
echo "==> fnm"
brew_install fnm

echo
echo "==> bun"
if cmd_installed bun; then
  echo "  skip: bun (already installed)"
else
  curl -fsSL https://bun.sh/install | bash
fi

echo
echo "==> uv"
brew_install uv

echo
echo "==> Apps"
brew_cask_install wezterm

echo
brew_cask_install zed

echo
brew_install orbstack

echo
echo "==> Dotfiles"
bash "$DOTFILES/install.sh"
