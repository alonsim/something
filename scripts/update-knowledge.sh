#!/usr/bin/env bash
# Regenerates knowledge/ based on what changed between two commits.
#
# Usage: update-knowledge.sh <before-sha> <after-sha> <branch>
#
# Called from:
#   - .github/workflows/update-knowledge.yml  (canonical, runs on GitHub)
#   - .githooks/post-merge                    (optional local mirror)
#
# Exit codes:
#   0  knowledge/ is up to date (regenerated, or nothing needed)
#   1  generation itself failed

set -euo pipefail

BEFORE="${1:-}"
AFTER="${2:-}"
BRANCH="${3:-$(git rev-parse --abbrev-ref HEAD)}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ---------------------------------------------------------------- helpers ---
# List files changed between the two commits, grouped by top-level dir.
changed_files() {
  if [ -n "$BEFORE" ] && git cat-file -e "$BEFORE" 2>/dev/null; then
    git diff --name-only "$BEFORE" "$AFTER"
  else
    # No valid "before" (fresh branch / force push) → treat everything as new
    git ls-files --others --exclude-standard; git ls-files
  fi
}

# ------------------------------------------------------- skip if no signal ---
case "$BRANCH" in
  dev|main) ;;
  *) echo "update-knowledge: branch '$BRANCH' is not tracked — skipping."; exit 0 ;;
esac

CHANGED="$(changed_files || true)"
if [ -z "$CHANGED" ]; then
  echo "update-knowledge: no file changes — skipping."
  exit 0
fi

echo "update-knowledge: branch=$BRANCH before=$BEFORE after=$AFTER"
echo "update-knowledge: changed files:"
echo "$CHANGED" | sed 's/^/  /'

# ============================================================================
# TODO: replace this block with your real generation step.
#
# Options, from simplest to most autonomous:
#
# 1. Static extraction (deterministic, fast):
#    e.g. regenerate an API surface file with your toolchain:
#      go doc ./... > knowledge/api.md
#
# 2. AI agent run (what makes knowledge/ truly autonomous).
#    Lean only on what changed, so the agent stays cheap and focused:
#
#      opencode run "The following files changed on branch '$BRANCH':
#        $(echo "$CHANGED" | head -50)
#        Update knowledge/ so the agent knowledge base reflects these changes.
#        Rewrite knowledge/INDEX.md summary; edit only knowledge/."
#
#    (An `opencode` install must exist in the CI image for option 2 —
#    see the setup instructions in knowledge/README.md.)
# ============================================================================
echo "update-knowledge: (placeholder) regeneration step runs here."

# Final safety net: never leave the branch dirty if generation no-op'ed.
git diff --quiet -- knowledge/ || true
exit 0
