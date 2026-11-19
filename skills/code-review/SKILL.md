---
name: code-review
description: "Review a GitHub PR (or the changes since a fixed point) on two axes: Standards and Spec. Reports findings with severity, then saves them as inline suggestion comments in a Pending review. Use when the user wants to review a PR, a branch, work-in-progress changes, or asks to \"review since X\"."
---

Two-axis review of a PR diff:

- **Standards**: does the code conform to this repo's documented coding standards and to modern web guidance?
- **Spec**: does the code faithfully implement the originating issue / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings. Start every sub-agent with a fresh context window.

## Severity

Every finding carries one severity prefix. Use only these four:

- `[Blocker]`: bug, security hole, data loss, or the spec is broken. Must fix before merge.
- `[Major]`: likely problem or a clear breach of a documented standard. Should fix before merge.
- `[Minor]`: real but small. Fix now or in a follow-up.
- `[Nit]`: taste or style. Optional.

Baseline smells (step 4) are judgement calls: rate them `[Minor]` or `[Nit]`.

## Writing style

Findings, the summary, and every PR comment follow these rules:

- Short sentences. One fact per sentence.
- Plain words that a non-native English reader understands. Say "check" not "scrutinize"; say "slow" not "suboptimal".
- Problem first, then the fix. Example: `[Major] \`user\` can be undefined here. Use \`user?.id\`.`
- At most 3 sentences per comment.
- Keep identifiers and file names exactly as written. No greeting, no thanks, no emoji.

## Process

### 1. Find the PR

Pick the repo directory, `REPO_DIR`: the current directory when its `origin` is the PR's repo; otherwise the clone listed for that repo under "Other Repos" in the project's `AGENTS.md`; otherwise ask the user.

Run `gh pr view [<number-or-url>] --json number,url,title,body,baseRefName,headRefName,headRefOid,state` in `REPO_DIR`. With no argument, it finds the PR of the checked-out branch.

- **PR found**: note number, base branch, head SHA (`headRefOid`), and body. Continue; step 8 will post comments.
- **No PR**: ask the user for a fixed point (commit SHA, branch, tag, `HEAD~5`). Review in chat only and skip step 8. Say "no PR, nothing posted" in the report.

### 2. Pin the checkout and the diff

Review the PR head commit, not whatever is checked out. `WT` is the directory the review reads from.

- **PR head is checked out** (`git -C "$REPO_DIR" rev-parse HEAD` equals `headRefOid`): `WT="$REPO_DIR"`. No worktree.
- **Any other case** (other branch, detached HEAD, local copy ahead or behind): create a throwaway worktree at the PR head. The user's checkout and uncommitted work stay untouched.

  ```sh
  git -C "$REPO_DIR" fetch origin pull/<number>/head
  WT="$(mktemp -d)/pr-<number>"
  git -C "$REPO_DIR" worktree add --detach "$WT" FETCH_HEAD
  git -C "$WT" rev-parse HEAD
  ```

  The last command must print `headRefOid`. If it differs, the PR got a new push: remove the worktree and redo step 1. `pull/<number>/head` also works for fork PRs.
- **No PR**: `WT="$REPO_DIR"` and the head is its current `HEAD`. When the user names another branch to review, add a worktree for it: `git -C "$REPO_DIR" worktree add --detach "$WT" <branch>`.

Read every repo file (standards, surrounding code) from `WT`. Get the diff:

- PR: `gh pr diff <number>` (run in `REPO_DIR`).
- No PR: `git -C "$WT" diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base).

Confirm the diff is non-empty and a bad ref fails here, not inside two parallel sub-agents.

### 3. Identify the spec source

Look for the originating spec, in this order:

1. The PR body, and any issue or Jira key in it (`PROJECT-123`, `Closes #45`). Fetch it with `gh issue view` or `jira issue view`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent skips and the report says "no spec available".

### 4. Identify the standards sources

Search the repo for every file that documents how code should be written (`AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.github/copilot-instructions.md`). Every one that exists must be on the list.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 5. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

**Standards sub-agent prompt** should include:

- The diff command, (for a PR) the PR number, and `WT`. Tell it to read repo files only from `WT`.
- The list of standards-source files from step 4, **plus the smell baseline from step 4** pasted in full (the sub-agent has no other access to it).
- When the diff touches HTML, CSS, or client-side JS/TSX: the instruction to invoke the `modern-web-guidance` skill for those hunks (search per web capability, retrieve the matching guides) and review the hunks against the retrieved guides. Cite the guide `id` in each finding. Skip the skill's "Disclose Skill Usage" section; this review does not deliver code. Skip the skill when the diff has no web UI code.
- The brief: "Report, per file/line, (a) every place the diff violates a documented standard or a retrieved modern-web guide: cite the standard (file + the rule) or the guide id; and (b) any baseline smell you spot: name it and quote the hunk. Give every finding a severity prefix from the scale below, the file path, and the line number in the new version of the file. When the fix is a small exact code change, add the replacement code for the line(s). Skip anything tooling enforces. Follow the writing style below. Under 400 words." Paste the Severity and Writing style sections into the prompt.

**Spec sub-agent prompt** should include:

- The diff command, (for a PR) the PR number, and `WT`. Tell it to read repo files only from `WT`.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Give every finding a severity prefix from the scale below, the file path, and the line number in the new version of the file (or 'no line' for a missing requirement). Follow the writing style below. Under 400 words." Paste the Severity and Writing style sections into the prompt.

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 6. Aggregate

Present the two reports under `## Standards` and `## Spec` headings. Inside each heading, list the findings as a to-fix list ordered Blocker → Nit, one line each: `[Severity] path:line — what to fix`. Do **not** merge or rerank findings across axes, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary per axis: count per severity. Don't pick a single winner across axes.

### 7. Check the inline comments

Turn each finding into an inline comment draft: `[Severity] <short text>`. For a finding with replacement code, add a suggestion block under the text:

````
[Minor] Use `const`. It is never reassigned.

```suggestion
const total = items.length;
```
````

- The suggestion block replaces the exact line(s) the comment is anchored to. Anchor on the changed line; for several lines, set `start_line` and `line`.
- Add a suggestion only when the replacement is exact. Otherwise write text only.
- A comment must anchor on a line that is inside the PR diff (added or context line, `side: RIGHT`). A finding with no such line goes into the review body, not into `comments`.

### 8. Submit a Pending review (PR only)

The review is **Pending only**. Pending means the user still has to open GitHub and submit it. Never send `event` (not `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`). Never submit, dismiss, or delete a review.

1. Check for an existing pending review. GitHub allows one per user per PR.

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '.[] | select(.state=="PENDING") | .id'
   ```

   If one exists, stop. Tell the user, show the drafts in chat, and ask what to do.

2. Write the payload to a temp file, then post it. The body is the step 6 to-fix list. `commit_id` is the head SHA from step 1.

   ```json
   {
     "commit_id": "<headRefOid>",
     "body": "<step 6 summary>",
     "comments": [
       { "path": "src/a.ts", "line": 12, "side": "RIGHT", "body": "[Major] ..." }
     ]
   }
   ```

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input <payload.json>
   ```

3. Verify the review is pending and has the expected comment count:

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/reviews/{review_id} --jq '.state'
   ```

   It must print `PENDING`. If the API returns 422 (a line is not in the diff), move that finding to the review body and post again.

End the chat report with the review URL and the line: "Pending review saved. Open the PR on GitHub to edit and submit it."

### 9. Clean up

When step 2 created a worktree (`WT` is not `REPO_DIR`), remove it, also when the run stops early:

```sh
git -C "$REPO_DIR" worktree remove "$WT" && rmdir "$(dirname "$WT")"
```

Remove only the worktree this run created. The review never edits files, so no `--force` is needed; if removal fails, tell the user the path.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
