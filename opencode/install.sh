#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# Symlinks for the plugin itself come from home-manager (home.nix).
# This only installs its dependency — bun resolves "@opencode-ai/plugin"
# from the plugin dir's realpath, so node_modules must live next to index.ts.
echo "==> opencode: install cursor-rules plugin deps"
(cd "$DOTFILES/opencode/plugins/cursor-rules" && bun install)
