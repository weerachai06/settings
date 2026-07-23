# generate-commit.sh — Conventional commit message generator via opencode
# Usage: source ~/scripts/generate-commit.sh
#
# Functions:
#   gen-commit    Generate a message from staged changes (preview only)
#   auto-commit   Generate -> confirm -> commit
#   quick-commit  Generate -> commit (no confirm)
#   commit-types  List conventional commit types
#   commit-help   Show usage

: "${COMMIT_MODEL:=opencode-go/deepseek-v4-flash}"

# Build the prompt fed to opencode for a given diff.
_commit_prompt() {
  cat <<EOF
Generate ONE conventional commit message for the staged changes below.

Output format (exactly — nothing else):
<type>(<domain>): <message>

<description text — one or two sentences, imperative mood, plain text>

Rules:
- type: feat | fix | docs | style | refactor | perf | test | chore | ci | build
- domain: the affected module/feature (e.g. auth, api, ui, db, tmux, skills)
- message: imperative mood, lowercase, no trailing period, <= 50 chars
- description: plain text, no bullet points, no code fences, no XML tags
- Output ONLY the header line + blank line + description. No extra commentary.

Examples:
feat(auth): add jwt token refresh

Adds a background token refresh so sessions stay alive beyond the
initial expiry without requiring a manual re-login.

fix(api): handle null response in parser

Parser threw an unhandled TypeError when the upstream service returned
a null body. Now returns an empty result instead.

Staged diff:
$1
EOF
}

# Generate a message from the staged diff and echo it to stdout.
# Output: "<title>\n\n<description body>" (git commit -m compatible).
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
  local raw
  raw="$(opencode run --print-logs -m "$COMMIT_MODEL" "$(_commit_prompt "$diff")" 2>/dev/null)"

  local title body
  title="$(echo "$raw" | grep -m1 -v '^[[:space:]]*$')"
  body="$(echo "$raw" | tail -n +2 | sed '/./,$!d')"

  if [ -z "$title" ]; then
    echo "❌ Failed to generate commit message" >&2
    return 1
  fi

  if [ -n "$body" ]; then
    printf '%s\n\n%s' "$title" "$body"
  else
    printf '%s' "$title"
  fi
}

# Generate, show, ask for confirmation, then commit.
auto-commit() {
  local msg
  msg="$(gen-commit)" || return 1

  echo "✓ Generated:" >&2
  echo "$msg" | sed 's/^/  /' >&2

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

# Print all conventional commit types with descriptions.
commit-types() {
  cat >&2 <<'EOF'
feat     — a new feature visible to users
fix      — a bug fix
docs     — documentation only, no code change
style    — formatting, whitespace, no logic change
refactor — restructure code without changing behaviour
perf     — measurable performance improvement
test     — add or fix tests, no production code change
chore    — tooling, deps, maintenance (no user-facing change)
ci       — CI/CD pipeline configuration
build    — build system or external dependency change
EOF
}

# Show usage for all commit functions and env knobs.
commit-help() {
  cat >&2 <<'EOF'
Conventional commit generator (opencode)

Commands:
  gen-commit     Analyse staged diff, print a suggested message (stdout only — no commit)
  auto-commit    gen-commit → show message → confirm → git commit
  quick-commit   gen-commit → git commit (skips confirmation prompt)
  commit-types   List all conventional commit types with descriptions
  commit-help    Show this help

Env:
  COMMIT_MODEL=opencode-go/deepseek-v4-pro   OpenCode model to use for generation
  COMMIT_INTERACTIVE=false                   Skip the y/n prompt (same as quick-commit)
  COMMIT_VERBOSE=1                           Print a banner when the file is sourced
EOF
}

# Set COMMIT_VERBOSE=1 to print a banner when sourced (off by default for shell startup).
[ -n "$COMMIT_VERBOSE" ] && echo "✓ Commit functions loaded! (gen-commit, auto-commit, quick-commit, commit-types, commit-help)" >&2
