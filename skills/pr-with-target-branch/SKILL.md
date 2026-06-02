---
name: pr-with-target-branch
description: Create a GitHub PR and prompt for target branch selection before creating. Use when making a pull request and need to specify which branch to merge into.
---

# Create PR with Target Branch

Creates a pull request and asks you to specify the target branch before submitting.

## Quick Start

When you need to create a PR:

1. Run `gh pr create` (without flags)
2. I'll prompt: "What target branch should this PR merge into?"
3. You provide the branch name (e.g., `dev`, `main`, `staging`)
4. PR is created targeting that branch

## Workflow

```
User: "Create a PR"
  ↓
Prompt: "Target branch?"
  ↓
User: "dev"
  ↓
Execute: gh pr create --base dev
```

## How to Use

Simply ask to create a PR. I will:

1. Ask: "What is the target branch?"
2. Wait for your input
3. Create the PR using `gh pr create --base <branch>`
4. Use current branch as source and commit message for PR title

## PR Template

After creating the PR, fill out the GitHub template with:
- **Title**: Follow `[WEB] description` format
- **Related JIRA**: Add ticket reference if applicable
- **Change Description**: Explain what and why
- **Type of change**: Mark the appropriate checkbox
- **Breaking change**: Specify if applicable
- **Test Evidence**: Show how you tested

See [REFERENCE.md](REFERENCE.md) for the complete template structure.

## Notes

- Requires GitHub CLI (`gh`) to be installed
- Works with any branch name
- PR title defaults to your latest commit message
- PR description defaults to extended commit message
