# 🌌 Antigravity Dotfiles: Multi-Agent Workspace Bootstrap Template

A production-grade, state-of-the-art configuration template for solo software developers seeking to optimize their workflow using agentic coding tools like **Google Antigravity**, **Claude Code**, or **Cursor**.

This repository contains a full set of custom system instructions, specialized agent skills, safety constraints, quality gates, and automated scripts that turn any codebase into an AI-native workspace.

---

## 🛠️ Repository Layout

```text
├── .agents/
│   ├── rules/                       # Industry-Standard Behavior Rules
│   │   ├── 01_orchestration_and_routing.md
│   │   ├── 02_architectural_design.md
│   │   ├── 03_test_driven_development.md
│   │   ├── 04_code_hygiene.md
│   │   ├── 05_security_and_privacy.md
│   │   └── 06_independent_validation.md
│   ├── skills/                      # Specialized Agent Capabilities
│   │   ├── architect/               # System & API contract design
│   │   ├── code-quality-auditor/    # Linting & code complexity checks
│   │   ├── test-coverage-runner/    # Automated testing & coverage validation
│   │   ├── security-auditor/        # Secret detection & CVE checking
│   │   ├── iv-v-verifier/           # Independent validation & verification
│   │   └── documentation-sync/      # Auto-updating documentation & APIs
│   └── agents/                      # Specialized Agent Definitions (Token-Optimized)
│       ├── architect/agent.json     # Uses Gemini 3.5 Pro (Low)
│       ├── linter/agent.json        # Uses Gemini 3.5 Flash (Low)
│       ├── tester/agent.json        # Uses Gemini 3.5 Flash (Low)
│       ├── security-auditor/agent.json # Uses Gemini 3.5 Pro (Thinking / High)
│       └── iv-v-verifier/agent.json # Uses Gemini 3.5 Pro (Low)
├── scripts/
│   ├── bootstrap.ps1                # Bootstrap workspace / Link config globally
│   └── verify-project.ps1           # Project validation runner
├── .antigravityignore               # Blocks indexing of unwanted/heavy folders
├── AGENTS.md                        # Root instruction manual for AI coding assistants
└── README.md                        # This file
```

---

## 🚀 Key Features

### 1. Token-Optimized Model Routing
To prevent token over-consumption, agent roles are assigned to specific Gemini models based on task complexity:
*   **Gemini 3.5 Flash (Low)**: Draws down **50% fewer credits/tokens** than standard Flash. Assigned to `Linter` and `Tester` roles for repetitive syntax and test runs.
*   **Gemini 3.5 Pro (Low)**: Bypasses high-overhead thinking token pools. Assigned to `Architect` and `IV&V Verifier` roles for robust logic without heavy premium multiples.
*   **Gemini 3.5 Pro (Thinking / High)**: Reserved exclusively for `Security Auditor` where deep reasoning is essential to block leakages or vulnerabilities.

### 2. Context Overhead Reduction (`.antigravityignore`)
Automatically configured in bootstrapped projects to prevent the AI from indexing or reading large dependency, cache, build, or media folders (such as `node_modules/`, `bin/`, `obj/`, `venv/`, `dist/`), saving thousands of context tokens on every query.

### 3. Git Pre-Commit Hook Integration
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
If you want these rules, skills, and token-optimized agent roles to be active across **all** Antigravity sessions on your machine:
Run the bootstrap script inside the `dotfiles` directory with the `-InstallGlobally` switch:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -InstallGlobally
```
This copies all custom agent configurations, rules, and skills into your global configuration directory (`~/.gemini/config/`).
