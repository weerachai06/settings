#!/usr/bin/env bash
# Copy these rules into <target-repo>/.claude/rules.
# Usage: bash agents/claude/rules/install.sh <target-repo>
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?usage: install.sh <target-repo>}"
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }

DEST="$TARGET/.claude/rules"
mkdir -p "$DEST"
for rule in "$SRC"/*.md; do
  cp "$rule" "$DEST/"
  echo "==> $(basename "$rule") -> $DEST"
done
