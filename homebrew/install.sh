#!/usr/bin/env bash
set -e
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/lib.sh"

LOCAL="$(dirname "$0")/.local"
if [ -f "$LOCAL" ]; then
  set -a
  # shellcheck source=homebrew/.local
  source "$LOCAL"
  set +a
fi

BREWFILE="$(dirname "$0")/Brewfile"

# brew bundle does not evaluate `unless ENV[...]` Ruby conditionals — build
# HOMEBREW_BUNDLE_BREW_SKIP from formulas whose feature flag is set in .local.
_skip_brews=""
while IFS= read -r line; do
  formula=$(echo "$line" | sed 's/brew "\([^"]*\)".*/\1/')
  flag=$(echo "$line" | sed -n 's/.*ENV\["\([^"]*\)"\].*/\1/p')
  if [ -n "$flag" ] && [ "${!flag}" == "1" ]; then
    echo "  skip: $formula ($flag=1)"
    _skip_brews="${_skip_brews} $formula"
  fi
done < <(grep '^brew ' "$BREWFILE")
export HOMEBREW_BUNDLE_BREW_SKIP="${_skip_brews# }"

# Detect casks already installed outside Homebrew to avoid adoption failures
# (e.g. xattr permission errors on SIP-protected files).
# Only check casks whose feature-flag env var isn't already set.
_casks=()
while IFS= read -r line; do
  cask=$(echo "$line" | sed 's/cask "\([^"]*\)".*/\1/')
  flag=$(echo "$line" | sed -n 's/.*ENV\["\([^"]*\)"\].*/\1/p')
  if [ -n "$flag" ] && [ "${!flag}" == "1" ]; then
    echo "  skip: $cask ($flag=1)"
  else
    _casks+=("$cask")
  fi
done < <(grep '^cask ' "$BREWFILE")
_skip_casks=""
if [ ${#_casks[@]} -gt 0 ]; then
  _cask_info=$(brew info --cask --json=v2 "${_casks[@]}" 2>/dev/null)
  while IFS='|' read -r token app_basename; do
    [ -z "$app_basename" ] && continue
    if [ -d "/Applications/$app_basename" ] && [ ! -d "$(brew --prefix)/Caskroom/$token" ]; then
      echo "  skip: $token (already installed at /Applications/$app_basename)"
      _skip_casks="${_skip_casks} $token"
    fi
  done < <(echo "$_cask_info" | python3 -c "
import sys, json, os
data = json.load(sys.stdin)
for c in data['casks']:
    app = ''
    for art in c['artifacts']:
        if 'app' in art:
            for a in art['app']:
                if isinstance(a, str):
                    app = os.path.basename(a)
                    break
        if app:
            break
    print(c['token'] + '|' + app)
")
  export HOMEBREW_BUNDLE_CASK_SKIP="${_skip_casks# }"
fi

echo "==> Homebrew packages"
brew bundle --file="$BREWFILE"
