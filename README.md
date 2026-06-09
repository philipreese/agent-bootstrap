# Agentic Workspace Dotfiles: Claude Code Bootstrap Template

A configuration template for solo software developers using **Claude Code** (VSCode extension or CLI). Contains system instructions, safety constraints, quality gates, and automated scripts that turn any codebase into an AI-native workspace.

---

## Repository Layout

```text
├── .claude/                         # Claude Code local rules and skills (created by bootstrap)
├── scripts/
│   ├── bootstrap.ps1                # Bootstrap workspace / link configs globally
│   └── verify-project.ps1           # Project validation runner
├── .claudeignore                    # Blocks indexing of heavy/irrelevant folders
├── CLAUDE.md                        # Root instruction manual for Claude Code
└── README.md                        # This file
```

---

## Key Features

### 1. Context Overhead Reduction (`.claudeignore`)
Prevents Claude Code from indexing large dependency, cache, build, or media folders (`node_modules/`, `bin/`, `obj/`, `.venv/`, `dist/`), saving context tokens on every query.

### 2. Git Pre-Commit Hook Integration
The bootstrapper registers a local Git `pre-commit` hook that runs `verify-project.ps1`.
- If code contains syntax errors, failing tests, or hardcoded secrets, Git will **abort the commit**.
- Runs locally for free — no agent tokens consumed for basic quality gates.

### 3. Quality Rules via `CLAUDE.md`
A concise set of workspace rules loaded into every Claude Code conversation:
- Conventional commits and branch naming (no direct commits to `main`)
- Contract-first architecture (define schemas before implementing)
- 80% branch coverage requirement
- Strict typing (no `any` / unannotated Python)
- No hardcoded secrets
- Docs sync (`README.md` + `CHANGELOG.md`) on every change

---

## Getting Started

### Bootstrapping a New Project
1. Open PowerShell in the target repository directory.
2. Run the bootstrap script pointing to your `dotfiles` checkout:
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\Users\pbree\source\repos\dotfiles\scripts\bootstrap.ps1
   ```

This copies rules, skills, and the verification script into your repository and configures the Git pre-commit hook.

### Linking Globally
To apply these rules across **all** Claude Code sessions on your machine, run the bootstrap from the `dotfiles` directory with the `-InstallGlobally` switch:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -InstallGlobally
```
This copies configurations into `~/.claude/`.
