#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# opencode2 (V2 beta) — published on the beta dist-tag. Installed via bun like
# the existing setup; lands in ~/.bun/bin, which home.nix puts on PATH only in
# the macOS-only zsh block (the linux config doesn't export it).
echo "==> opencode: install opencode2 (V2 beta)"
bun add -g @opencode-ai/cli@beta

# Plugin symlinks come from home-manager (home.nix). This only installs the
# plugin dependency — bun resolves "@opencode-ai/plugin" from the plugin dir's
# realpath, so node_modules must live next to index.ts.
echo "==> opencode: install cursor-rules plugin deps"
(cd "$DOTFILES/opencode/plugins/cursor-rules" && bun install)
