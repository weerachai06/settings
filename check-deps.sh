#!/usr/bin/env bash
# Checks that all dotfile dependencies are present on this machine.

PASS=0
FAIL=0

ok()      { echo "  ✅  $1"; PASS=$((PASS + 1)); }
missing() { echo "  ❌  $1"; FAIL=$((FAIL + 1)); }

check_cmd() {
  local name="$1" cmd="${2:-$1}"
  command -v "$cmd" &>/dev/null && ok "$name ($cmd)" || missing "$name — install: $3"
}

check_dir() {
  local name="$1" path="$2" hint="$3"
  [ -d "$path" ] && ok "$name ($path)" || missing "$name — $hint"
}

check_app() {
  local name="$1"
  [ -d "/Applications/${name}.app" ] && ok "$name" || missing "$name — install from brew or official site"
}

check_brew_pkg() {
  local pkg="$1"
  [ -d "$(brew --prefix "$pkg" 2>/dev/null)" ] && ok "$pkg (brew)" || missing "$pkg — brew install $pkg"
}

# ── Core ──────────────────────────────────────────────────────────────────────
echo
echo "Core"
check_cmd "Homebrew"   brew   "https://brew.sh"
check_cmd "Git"        git    "brew install git"

# ── Zsh ───────────────────────────────────────────────────────────────────────
echo
echo "Zsh"
check_dir "Oh My Zsh"  "$HOME/.oh-my-zsh"   "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
check_cmd "fnm"        fnm    "brew install fnm"
check_cmd "bun"        bun    "https://bun.sh — curl -fsSL https://bun.sh/install | bash"
check_cmd "uv"         uv     "brew install uv  OR  curl -LsSf https://astral.sh/uv/install.sh | sh"
check_brew_pkg "openssl@3"
check_brew_pkg "zsh-autosuggestions"
check_brew_pkg "zsh-syntax-highlighting"

# ── Rust ──────────────────────────────────────────────────────────────────────
echo
echo "Rust"
check_dir "Cargo"      "$HOME/.cargo"       "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"

# ── Apps ──────────────────────────────────────────────────────────────────────
echo
echo "Apps"
check_app "WezTerm"
check_app "Zed"
check_dir "OrbStack"   "$HOME/.orbstack"    "brew install --cask orbstack"

# ── gh-pr-notifier ────────────────────────────────────────────────────────────
echo
echo "gh-pr-notifier"
check_cmd "GitHub CLI" gh     "brew install gh"
check_cmd "Python 3"   python3 "brew install python3"
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    ok "gh authenticated"
  else
    missing "gh not authenticated — run: gh auth login"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo
echo "────────────────────────────────"
echo "  Passed: $PASS  |  Missing: $FAIL"
echo "────────────────────────────────"
echo

[ "$FAIL" -eq 0 ]
