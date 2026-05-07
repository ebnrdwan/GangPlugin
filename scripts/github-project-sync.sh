#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Gang GitHub Project Sync  v1.0.0
# ─────────────────────────────────────────────────────────────
# Creates (or updates) a GitHub Issue from a Gang evaluation
# and optionally adds it to a GitHub Projects v2 board.
#
# Requirements: gh CLI (https://cli.github.com) authenticated
#               with 'repo' and 'project' scopes.
#
# Usage:
#   ./github-project-sync.sh \
#     --title    "Gang: feature-name — CONDITIONAL-GO"  \
#     --body-file /tmp/gang-issue-body.md               \
#     [--project-number 3]                              \
#     [--label   gang-evaluation]                       \
#     [--milestone "v2.0"]                              \
#     [--issue-number 42]                               \  (update existing issue)
#     [--dry-run]
#
# Exit codes:
#   0  success
#   1  bad arguments
#   2  gh CLI not found or not authenticated
#   3  not a GitHub repository
#   4  issue creation / update failed
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────
TITLE=""
BODY_FILE=""
PROJECT_NUMBER=""
LABEL="gang-evaluation"
MILESTONE=""
ISSUE_NUMBER=""   # if set: update existing issue instead of creating
DRY_RUN=false

# ── Argument parsing ──────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --title)          TITLE="$2";          shift 2 ;;
    --body-file)      BODY_FILE="$2";      shift 2 ;;
    --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
    --label)          LABEL="$2";          shift 2 ;;
    --milestone)      MILESTONE="$2";      shift 2 ;;
    --issue-number)   ISSUE_NUMBER="$2";   shift 2 ;;
    --dry-run)        DRY_RUN=true;        shift   ;;
    *) echo "❌  Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Validation ────────────────────────────────────────────────
[[ -z "$TITLE"     ]] && { echo "❌  --title is required"               >&2; exit 1; }
[[ -z "$BODY_FILE" ]] && { echo "❌  --body-file is required"           >&2; exit 1; }
[[ -f "$BODY_FILE" ]] || { echo "❌  Body file not found: $BODY_FILE"   >&2; exit 1; }

# ── Pre-flight: gh CLI ────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  cat >&2 <<EOF
❌  gh CLI not found.

Install it from https://cli.github.com, then authenticate:
  gh auth login --scopes repo,project

EOF
  exit 2
fi

if ! gh auth status &>/dev/null; then
  cat >&2 <<EOF
❌  gh CLI is not authenticated.

Run:  gh auth login --scopes repo,project

EOF
  exit 2
fi

# ── Detect repo ───────────────────────────────────────────────
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [[ -z "$REPO" ]]; then
  cat >&2 <<EOF
❌  Not inside a GitHub repository (or no remote configured).

Run this script from your project root where 'gh repo view' works.

EOF
  exit 3
fi
OWNER="${REPO%%/*}"

# ── Dry run ───────────────────────────────────────────────────
if $DRY_RUN; then
  echo "════════════════════════════════════════"
  echo "  DRY RUN — nothing will be created"
  echo "════════════════════════════════════════"
  echo "  Repo:    $REPO"
  echo "  Title:   $TITLE"
  echo "  Label:   $LABEL"
  echo "  Project: ${PROJECT_NUMBER:-none}"
  [[ -n "$MILESTONE"    ]] && echo "  Milestone: $MILESTONE"
  [[ -n "$ISSUE_NUMBER" ]] && echo "  Update issue #$ISSUE_NUMBER"
  echo ""
  echo "── Issue body ──────────────────────────"
  cat "$BODY_FILE"
  echo "────────────────────────────────────────"
  exit 0
fi

# ── Ensure label exists ───────────────────────────────────────
gh label create "$LABEL" \
  --color "6e40c9" \
  --description "Gang multi-agent committee evaluation" \
  --repo "$REPO" 2>/dev/null || true   # ignore if already exists

# ── Create or update the issue ────────────────────────────────
if [[ -n "$ISSUE_NUMBER" ]]; then
  # UPDATE existing issue (re-push after /gang deliver)
  echo "Updating GitHub Issue #$ISSUE_NUMBER in $REPO..."

  GH_EDIT_ARGS=("issue" "edit" "$ISSUE_NUMBER"
    --title "$TITLE"
    --body-file "$BODY_FILE")
  [[ -n "$MILESTONE" ]] && GH_EDIT_ARGS+=(--milestone "$MILESTONE")

  if ! gh "${GH_EDIT_ARGS[@]}"; then
    echo "❌  Failed to update issue #$ISSUE_NUMBER" >&2; exit 4
  fi

  ISSUE_URL=$(gh issue view "$ISSUE_NUMBER" --json url -q .url)
  echo "✓  Issue updated: $ISSUE_URL"

else
  # CREATE new issue
  echo "Creating GitHub Issue in $REPO..."

  GH_CREATE_ARGS=("issue" "create"
    --title "$TITLE"
    --body-file "$BODY_FILE"
    --label "$LABEL")
  [[ -n "$MILESTONE" ]] && GH_CREATE_ARGS+=(--milestone "$MILESTONE")

  ISSUE_URL=$(gh "${GH_CREATE_ARGS[@]}" 2>&1) || {
    echo "❌  Failed to create issue: $ISSUE_URL" >&2; exit 4
  }
  echo "✓  Issue created: $ISSUE_URL"
fi

# ── Add to GitHub Project (v2) ────────────────────────────────
if [[ -n "$PROJECT_NUMBER" && "$PROJECT_NUMBER" != "0" ]]; then
  echo "Adding to GitHub Project #$PROJECT_NUMBER..."
  if gh project item-add "$PROJECT_NUMBER" \
       --owner "$OWNER" \
       --url   "$ISSUE_URL" 2>/dev/null; then
    echo "✓  Added to project #$PROJECT_NUMBER"
  else
    echo "⚠  Could not add to project #$PROJECT_NUMBER"
    echo "   (Check that you have 'project' scope: gh auth refresh --scopes project)"
    echo "   Issue is still available: $ISSUE_URL"
  fi
fi

# ── Final output ──────────────────────────────────────────────
echo ""
echo "ISSUE_URL=$ISSUE_URL"
