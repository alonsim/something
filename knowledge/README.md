# Knowledge base for agents

This folder is the shared knowledge base for every agent that touches this
codebase. It is **generated, not hand-edited**: it is automatically updated
whenever `dev` or `main` advances.

## How updates work

1. **CI (canonical).** Every push to `dev` or `main` runs
   `.github/workflows/update-knowledge.yml`, which:
   - diffs the new commit against the previous one,
   - calls `scripts/update-knowledge.sh` with both SHAs,
   - commits the result back with `[skip ci]` in the message (loop guard).

2. **Local mirror (optional).** `git pull` runs the same script via a
   `post-merge` hook. Enable with:
   ```sh
   git config core.hooksPath .githooks
   ```

## Conventions

| File | Purpose |
|---|---|
| `INDEX.md` | Entry point — what this project is, where everything lives |
| `architecture.md` | How the system fits together |
| `changelog.md` | Running summary of notable changes per branch |
| `conventions.md` | Code style, patterns, and rules agents must follow |

Rules for the generator (also enforced by CI):
- Only files inside `knowledge/` may be created or modified.
- Commits to these files are made by `knowledge-bot` and carry `[skip ci]`.
- If a human wants to change knowledge permanently, change the *generator*
  (the script / agent prompt), not the output — the next run would overwrite it.
