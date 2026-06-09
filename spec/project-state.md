# Project State: agent-bootstrap

## Purpose

A dotfiles/template repo that bootstraps any codebase into a Claude Code-native AI workspace. Running `bootstrap.ps1` against a target repo installs:

- `CLAUDE.md` — workspace rules loaded into every Claude Code conversation
- `.claude/` — local Claude Code commands and settings scaffold
- `.claudeignore` — context reduction (excludes `node_modules/`, build dirs, etc.)
- `scripts/verify-project.ps1` — quality gate (secrets, git conventions, linting)
- Git pre-commit hook — auto-runs verify-project.ps1 before every commit

---

## File Structure

```
agent-bootstrap/
├── .claude/                    # Claude Code commands/settings scaffold (copied to target projects)
├── spec/                       # Project specification and state (this folder)
│   └── project-state.md
├── scripts/
│   ├── bootstrap.ps1           # Installs workspace config into a target repo or globally
│   └── verify-project.ps1     # Quality gate: secrets, git naming, conventional commits, linters
├── .claudeignore               # Tells Claude Code what NOT to index
├── .gitignore
├── CLAUDE.md                   # Root AI instruction manual (loaded every conversation)
└── README.md
```

---

## Current State (as of 2026-06-08)

### Completed

- [x] Removed all Antigravity (Google Gemini CLI) artifacts: `AGENTS.md`, `.antigravityignore`, `.agents/` directory, `scratch/` directory
- [x] Rewrote `CLAUDE.md` to use Claude Code-native concepts (Plan mode, subagents, TodoWrite) instead of Antigravity's named-agent hierarchy (`invoke_subagent`)
- [x] Rewrote `scripts/bootstrap.ps1` — Claude Code only; removed `-Tool` parameter and all Antigravity branching
- [x] Updated `README.md` — removed all Gemini/Antigravity references
- [x] Cleaned `.gitignore` — removed `.gemini/` entry
- [x] Verified no Antigravity references remain in any tracked file

### Rules in CLAUDE.md

| # | Rule | Key Constraint |
|---|------|----------------|
| 1 | Git & Commit Standards | No commits to `main`; conventional commits format |
| 2 | Architectural Integrity | Separation of concerns; contract-first design |
| 3 | Test-Driven Development | 80% branch coverage; mock external services |
| 4 | Code Hygiene | No `any` in TS; no unannotated Python; use Pixi |
| 5 | Security & Secrets | No hardcoded credentials; validate all inputs |
| 6 | Documentation Sync | Keep README, CHANGELOG, and `/spec` up to date |

### bootstrap.ps1 Behavior

| Mode | Command | Effect |
|------|---------|--------|
| Local (default) | `.\scripts\bootstrap.ps1 -TargetPath <path>` | Copies all config into target repo, wires pre-commit hook |
| Global | `.\scripts\bootstrap.ps1 -InstallGlobally` | Copies `CLAUDE.md` to `~/.claude/` for all sessions |

---

## Pending / Future Work

- [ ] Add `.claude/commands/` example slash commands to the scaffold (e.g. `/verify`, `/spec-update`)
- [ ] Consider CHANGELOG.md — currently absent from this repo
- [ ] Evaluate whether `verify-project.ps1` should support Pixi-detected environments explicitly (currently falls through to raw linter binaries)
