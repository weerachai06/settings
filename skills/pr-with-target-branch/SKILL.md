---
name: pr-with-target-branch
description: Create a GitHub PR and prompt for target branch selection before creating. Use when making a pull request and need to specify which branch to merge into.
---

# Create PR with Target Branch

Creates a pull request and asks you to specify the target branch before submitting.

## Quick Start

When you need to create a PR:

1. Run `gh pr create` (without flags)
2. I'll prompt: "What target branch should this PR merge into?" and "What source branch?" (defaults to current branch)
3. You provide the branch names (e.g., target `dev`, `main`, `staging`)
4. PR is created between those branches

## Workflow

```
User: "Create a PR"
  ↓
Prompt: "Target branch?"
  ↓
User: "dev"
  ↓
Prompt: "Source branch? (default: current branch)"
  ↓
User: "" (accepts default) or "feature/foo"
  ↓
Execute: gh pr create --base dev --head feature/foo
```

## How to Use

Simply ask to create a PR. I will:

1. Ask: "What is the target branch?"
2. Wait for your input
3. Ask: "What is the source branch?", showing the current branch as the default — wait for confirmation before assuming it
4. **Gate — read template before create**: read [REFERENCE.md](REFERENCE.md) first. Never run `gh pr create --body ...` before this.
5. **Gate — diff before describing**: run `git diff origin/<target-branch>...origin/<source-branch>` to see the actual changes against origin. Never write the Change Description before this.
6. Create the PR using `gh pr create --draft --base <target-branch> --head <source-branch> --body <filled template>`

## PR Template

Template source: [REFERENCE.md](REFERENCE.md), read in step 4 above.

Fill out the template with:
- **Title**: Follow `[JIRA-TICKET-NUMBER] short description` format
- **Related JIRA**: Add ticket reference if applicable
- **Change Description**: Write as bullet points explaining what and why, grounded in the `git diff` from step 5
- **Type of change**: Mark the appropriate checkbox
- **Breaking change**: Specify if applicable
- **Test Evidence**: Show how you tested

**Exception — release flow**: if the source/target branch pair matches one of these, use the Release Flow Templates in [REFERENCE.md](REFERENCE.md) instead of the JIRA-ticket format above:
- `releases/*` → `main`: **Release**
- `sprint` → `dev`: **Release**
- `releases/*` → `dev`: **Merge Down**
- `dev` → `sprint`: **Merge Down**

See [REFERENCE.md](REFERENCE.md) for the complete template structures.

## Notes

- Requires GitHub CLI (`gh`) to be installed
- Works with any branch name
- PR title defaults to your latest commit message
- PR description defaults to extended commit message
