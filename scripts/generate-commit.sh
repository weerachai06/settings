# generate-commit.sh — Conventional commit message generator via opencode
# Usage: source ~/scripts/generate-commit.sh
#
# Functions:
#   gen-commit    Generate a message from staged changes (preview only)
#   auto-commit   Generate -> confirm -> commit
#   quick-commit  Generate -> commit (no confirm)
#   commit-types  List conventional commit types
#   commit-help   Show usage

: "${COMMIT_MODEL:=opencode-go/deepseek-v4-pro}"

# Build the prompt fed to opencode for a given diff.
_commit_prompt() {
  cat <<EOF
Generate ONE conventional commit message for the staged changes below.

Format (exactly):
<type>(<domain>): <message>

Rules:
- type: feat | fix | docs | style | refactor | perf | test | chore | ci | build
- domain: the affected module/feature (e.g. auth, api, ui, db, tmux, skills)
- message: imperative mood, lowercase, no trailing period, <= 50 chars
- Output ONLY the single message line. No quotes, no code fences, no explanation.

Examples:
  feat(auth): add jwt token refresh
  fix(api): handle null response in parser
  docs(readme): update installation steps

Staged diff:
$1
EOF
}

# Generate a message from the staged diff and echo it to stdout.
gen-commit() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Not inside a git repository" >&2
    return 1
  fi

  local diff
  diff="$(git diff --cached)"
  if [ -z "$diff" ]; then
    echo "❌ No staged changes (use 'git add' first)" >&2
    return 1
  fi

  echo "📋 Generating commit message (model: $COMMIT_MODEL)..." >&2
  local msg
  msg="$(opencode run --print-logs -m "$COMMIT_MODEL" "$(_commit_prompt "$diff")" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -n 1)"

  if [ -z "$msg" ]; then
    echo "❌ Failed to generate commit message" >&2
    return 1
  fi
  echo "$msg"
}

# Generate, show, ask for confirmation, then commit.
auto-commit() {
  local msg
  msg="$(gen-commit)" || return 1

  echo "✓ Generated:" >&2
  echo "  $msg" >&2

  if [ "${COMMIT_INTERACTIVE:-true}" = "false" ]; then
    git commit -m "$msg" && echo "✅ Committed!" >&2
    return $?
  fi

  printf "✓ Commit this? (y/n) " >&2
  local reply
  read -r reply
  case "$reply" in
    [Yy]*) git commit -m "$msg" && echo "✅ Committed!" >&2 ;;
    *)     echo "❌ Aborted" >&2; return 1 ;;
  esac
}

# Generate and commit without confirmation.
quick-commit() {
  COMMIT_INTERACTIVE=false auto-commit
}

commit-types() {
  cat >&2 <<'EOF'
feat     — a new feature
fix      — a bug fix
docs     — documentation only
style    — formatting, no code change
refactor — code change that neither fixes a bug nor adds a feature
perf     — performance improvement
test     — adding or fixing tests
chore    — tooling / maintenance
ci       — CI configuration
build    — build system or dependencies
EOF
}

commit-help() {
  cat >&2 <<'EOF'
Conventional commit generator (opencode)

  gen-commit     Generate a message from staged changes (prints to stdout)
  auto-commit    Generate -> confirm -> commit
  quick-commit   Generate -> commit (no confirm)
  commit-types   List commit types
  commit-help    This help

Env:
  COMMIT_MODEL=opencode-go/deepseek-v4-pro   model to use
  COMMIT_INTERACTIVE=false                   skip the confirm prompt
EOF
}

# Set COMMIT_VERBOSE=1 to print a banner when sourced (off by default for shell startup).
[ -n "$COMMIT_VERBOSE" ] && echo "✓ Commit functions loaded! (gen-commit, auto-commit, quick-commit, commit-types, commit-help)" >&2
