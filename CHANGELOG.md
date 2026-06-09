# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `CHANGELOG.md` to satisfy Rule 6 (Documentation Sync) — previously absent from the repo
- Pixi environment detection in `verify-project.ps1`: when `pixi.toml` is present and `pixi` is in PATH, linting and tests run via `pixi run lint` / `pixi run test` instead of raw binaries

## [1.0.0] - 2026-06-08

### Added
- `CLAUDE.md` — workspace rules for Claude Code (Plan mode, subagents, TodoWrite, conventional commits, Pixi, etc.)
- `scripts/verify-project.ps1` — quality gate covering secret scanning, branch/commit conventions, documentation sync, and multi-language linting (Node, Python, .NET, Go)
- `scripts/bootstrap.ps1` — installs workspace config (`CLAUDE.md`, `.claude/`, `.claudeignore`, `verify-project.ps1`, pre-commit hook) into any target repo or globally to `~/.claude/`
- `.claudeignore` — context reduction file excluding `node_modules/`, build dirs, and generated artifacts
- `.claude/` scaffold — local Claude Code commands and settings copied to bootstrapped repos
- `spec/project-state.md` — living document tracking project goals, completed work, and pending items
- Git pre-commit hook wired by `bootstrap.ps1` to auto-run `verify-project.ps1` before every commit
- `__PROJECT_ROOT__` placeholder in manuals and bootstrapper for portable dotfile paths
- Pixi environment guidelines and ignore rules

### Changed
- Rewrote entire workspace from Antigravity (Google Gemini CLI) to Claude Code-native architecture
- Replaced Antigravity's named-agent hierarchy (`invoke_subagent`) with Claude Code concepts (Plan mode, Explore/Plan subagents, TodoWrite)
- Rewrote `bootstrap.ps1` to be Claude Code only — removed `-Tool` parameter and all Antigravity branching
- Updated `README.md` to remove all Gemini/Antigravity references

### Removed
- All Antigravity artifacts: `AGENTS.md`, `.antigravityignore`, `.agents/` directory, `scratch/` directory
- `.gemini/` entry from `.gitignore`
