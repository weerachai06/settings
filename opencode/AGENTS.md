# Agents — Global Instructions

## Task Scope & Completion

- **Break every task into 3–7 bullets.** If a task needs more than 7 steps, split it into smaller sub-tasks first.
- **After completing a task, always end with a two-part summary:**
  - ✅ **Done** — what was completed in this turn.
  - ⬜ **Remaining** — what is still missing or left to do (write "nothing" if fully done).

## Before Every Implementation

- **Show the plan first.** Present a concise implementation plan and wait for confirmation before writing any code.
- **Cite your references.** State which files, functions, or docs informed the approach before acting on it.

## Uncertainty & Hardcoding

- **Don't implement what you're not sure about.** If the right approach is unclear, ask an open question instead of guessing or hardcoding a value.
- **No speculative or placeholder code.** Only implement what is well-understood and properly derived from the codebase.

## Bug Fixes

- **Find evidence before fixing.** Identify the root cause through logs, code inspection, or reproduction — not intuition.
- **No interim solutions.** Don't apply band-aids or workarounds that paper over the real problem.

## Environment

- **Never use the system `/tmp` directory.** For temporary files or experiments, use a `./tmp` folder at the project root instead — it stays close to the code and is gitignored globally.
- **Run `fnm use` before every shell/Bash command** that depends on Node.js or npm, so the correct Node version is active in the shell.
