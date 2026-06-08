# 🧼 Rule 04: Code Hygiene & Static Analysis

## 1. Goal
To maintain high readability, consistency, and simplicity in the codebase by enforcing strict type systems, linting rules, and complexity gates.

## 2. Type Safety & Linting
- **Strict Typing**: Enable and adhere to strict mode flags (e.g. `strict: true` in typescript, type hints in python with mypy). Never use `any` or untyped fallbacks unless absolutely unavoidable.
- **Linter Conformity**: Zero linter warnings or errors are tolerated in committed code. Run local linters prior to completing a task.
- **Code Style**: Follow standard language guidelines (e.g., PEP 8 for Python, Prettier/ESLint for JavaScript/TypeScript, standard rules for C#/.NET).

## 3. Complexity Gates
- **Cognitive Complexity**: Keep functions small. A single function should not exceed 25 lines or have a cyclomatic complexity greater than 10.
- **DRY (Don't Repeat Yourself)**: Refactor repeating code blocks into reusable utilities, helper classes, or hooks.
- **File Structure**: Keep file directories clean, organized, and properly named according to project idioms.

## 4. Documentation & Comments
- **Self-documenting Code**: Prefer clear variable and function names over verbose comments.
- **Docstrings**: Include descriptive docstrings/comments for exported interfaces, public classes, and complex algorithms.
