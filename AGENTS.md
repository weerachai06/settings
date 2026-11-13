# Home Repo

Home base for my coding agents. Run the agent from here. It holds my shared
skills and global instructions, and points at the repos I work in.

## Layout

- `skills/` — my own skills. `skills/install.sh` links them into
  `~/.claude/skills`, `~/.config/opencode/skills` and `~/.kiro/skills`.
- `claude/`, `kiro/`, `opencode/` — global instructions and subagents per tool.
  `~/.dotfiles/home.nix` links them into place.
- Skills installed from published repos are not stored here.

## Other Repos

- kpc-web-frontend-2 (KPC Web Frontend 2, Next.js 15 + TypeScript app): ~/Documents/projects/kpc-web-frontend-2. Clone from git@github.com:kingpowerclick/kpc-web-frontend-2.git if missing. Read its AGENTS.md first.
- kpc-web-backoffice-2 (Back Office 2.0): ~/Documents/projects/kpc-web-backoffice-2. Clone from git@github.com:kingpowerclick/kpc-web-backoffice-2.git if missing. Read its AGENTS.md first.
- kpc-web-frontend (KP Web Frontend): ~/Documents/projects/kpc-web-frontend. Clone from git@github.com:kingpowerclick/kpc-web-frontend.git if missing. No AGENTS.md; see .github/copilot-instructions.md.
- crown-design-tokens (Crown design tokens monorepo): ~/Documents/projects/crown-design-tokens. Clone from git@github.com:kingpowerclick/crown-design-tokens.git if missing. Read its CLAUDE.md first (its AGENTS.md only points there); CONTEXT.md has the glossary.
- .dotfiles (Nix home-manager dotfiles): ~/.dotfiles. Clone from git@github.com:weerachai06/settings.git if missing. Read its AGENTS.md first.
