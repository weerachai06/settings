#!/usr/bin/env bash
# Shared helpers — source this file, do not execute it directly.

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "  backed up: $dst"
  fi
  ln -sf "$src" "$dst"
  echo "  linked: $dst"
}

unlink_path() {
  local dst="$1"
  if [ -L "$dst" ]; then
    rm "$dst"
    echo "  removed: $dst"
  fi
}

brew_install() {
  if brew list "$1" &>/dev/null 2>&1; then
    echo "  skip: $1 (already installed)"
  else
    brew install "$1"
  fi
}

brew_cask_install() {
  if brew list --cask "$1" &>/dev/null 2>&1; then
    echo "  skip: $1 (already installed)"
  else
    brew install --cask "$1"
  fi
}

cmd_installed() {
  command -v "$1" &>/dev/null
}
