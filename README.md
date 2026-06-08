# 🌌 Agentic Workspace Dotfiles: Multi-Agent Workspace Bootstrap Template

A production-grade, state-of-the-art configuration template for solo software developers seeking to optimize their workflow using agentic coding tools like **Google Antigravity**, **Claude Code**, or **Cursor**.

This repository contains a full set of custom system instructions, specialized agent skills, safety constraints, quality gates, and automated scripts that turn any codebase into a tool-agnostic, AI-native workspace.

---

## 🛠️ Repository Layout & Bootstrapped Structure

When you bootstrap a project, the following structures and files are created/configured:

```text
├── .agents/                         # Antigravity local rules, skills, and agent configs
├── .claude/                         # Claude Code local rules and skills
├── scripts/
│   ├── bootstrap.ps1                # Bootstrap workspace / Link configs globally
│   └── verify-project.ps1           # Project validation runner
├── .antigravityignore               # Blocks indexing of unwanted/heavy folders (Antigravity)
├── .claudeignore                    # Blocks indexing of unwanted/heavy folders (Claude Code)
├── AGENTS.md                        # Root instruction manual for Antigravity CLI
├── CLAUDE.md                        # Root instruction manual for Claude Code
└── README.md                        # This file
```

---

## 🚀 Key Features

### 1. Tool-Agnostic Support (Antigravity & Claude Code)
Configures and maintains aligned system instructions, ignoring patterns, and specialized agent capabilities for both Antigravity CLI and Claude Code, ensuring a seamless experience regardless of the tool.

### 2. Token-Optimized Model Routing (Antigravity)
To prevent token over-consumption, agent roles are assigned to specific Gemini models based on task complexity:
*   **Gemini 3.5 Flash (Low)**: Draws down **50% fewer credits/tokens** than standard Flash. Assigned to `Linter` and `Tester` roles for repetitive syntax and test runs.
*   **Gemini 3.5 Pro (Low)**: Bypasses high-overhead thinking token pools. Assigned to `Architect` and `IV&V Verifier` roles for robust logic without heavy premium multiples.
*   **Gemini 3.5 Pro (Thinking / High)**: Reserved exclusively for `Security Auditor` where deep reasoning is essential to block leakages or vulnerabilities.

### 3. Context Overhead Reduction (`.antigravityignore` & `.claudeignore`)
Automatically configured in bootstrapped projects to prevent the AI from indexing or reading large dependency, cache, build, or media folders (such as `node_modules/`, `bin/`, `obj/`, `venv/`, `dist/`), saving thousands of context tokens on every query.

### 4. Git Pre-Commit Hook Integration
The bootstrapper automatically registers a local Git `pre-commit` hook that runs `verify-project.ps1`.
*   If your code contains syntax errors, unformatted blocks, failing tests, or hardcoded secrets, Git will **abort the commit**.
*   This quality gate executes locally on your CPU for **free**, ensuring code is clean before committing without triggering expensive agent audit loops.

---

## 💻 Getting Started

### 1. Bootstrapping a New Project
To quickly inject this multi-agent structure into any repository:
1. Open PowerShell in the target repository directory.
2. Run the bootstrap script pointing to your `dotfiles` checkout:
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\Users\pbree\source\repos\dotfiles\scripts\bootstrap.ps1
   ```

The script will copy the rules, skills, agent roles, and verification scripts into your new repository, configure Git hooks, and prepare your project for autonomous validation.

### 2. Linking Globally
If you want these rules, skills, and token-optimized agent roles to be active across **all** agent sessions on your machine:
Run the bootstrap script inside the `dotfiles` directory with the `-InstallGlobally` switch:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -InstallGlobally
```
This copies all custom agent configurations, rules, and skills into:
- Antigravity global configuration directory: `~/.gemini/antigravity-cli/`
- Claude Code global configuration directory: `~/.claude/`
