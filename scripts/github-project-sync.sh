#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Gang GitHub Project Sync  v2.0.0
# ─────────────────────────────────────────────────────────────
# Adds a Gang evaluation result as a DRAFT ITEM directly on a
# GitHub Projects v2 board — no issue created.
#
# Falls back to creating a regular GitHub Issue when no project
# number is supplied (--project-number 0 or omitted).
#
# Requirements: gh CLI (https://cli.github.com) authenticated
#               with 'project' scope (+ 'repo' for issue fallback)
#
#   gh auth login --scopes project,repo
#
# Usage:
#   ./github-project-sync.sh \
#     --title          "Gang: feature-name — CONDITIONAL-GO"  \
#     --body-file      /tmp/gang-issue-body.md                \
#     --project-number 3                                      \
#     [--owner         myorg]      (default: auto-detect)     \
#     [--label         gang-evaluation]  (issue fallback only) \
#     [--milestone     "v2.0"]           (issue fallback only) \
#     [--dry-run]
#
# Exit codes:
#   0  success
#   1  bad arguments
#   2  gh CLI not found or not authenticated
#   3  not a GitHub repository (issue fallback only)
#   4  project item / issue creation failed
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────
TITLE=""
BODY_FILE=""
PROJECT_NUMBER="0"
OWNER=""
LABEL="gang-evaluation"
MILESTONE=""
ASSIGNEE=""
PRIORITY=""     # e.g. P1, P2, P3 — matched against project field options
SIZE=""         # e.g. S, M, L, XL — matched against project field options
DRY_RUN=false

# ── Argument parsing ──────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --title)          TITLE="$2";          shift 2 ;;
    --body-file)      BODY_FILE="$2";      shift 2 ;;
    --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
    --owner)          OWNER="$2";          shift 2 ;;
    --label)          LABEL="$2";          shift 2 ;;
    --milestone)      MILESTONE="$2";      shift 2 ;;
    --assignee)       ASSIGNEE="$2";       shift 2 ;;
    --priority)       PRIORITY="$2";       shift 2 ;;
    --size)           SIZE="$2";           shift 2 ;;
    --dry-run)        DRY_RUN=true;        shift   ;;
    *) echo "❌  Unknown option: $1" >&2; exit 1   ;;
  esac
done

# ── Validation ────────────────────────────────────────────────
[[ -z "$TITLE"     ]] && { echo "❌  --title is required"             >&2; exit 1; }
[[ -z "$BODY_FILE" ]] && { echo "❌  --body-file is required"         >&2; exit 1; }
[[ -f "$BODY_FILE" ]] || { echo "❌  Body file not found: $BODY_FILE" >&2; exit 1; }

# ── Pre-flight: gh CLI ────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  cat >&2 <<EOF
❌  gh CLI not found.

Install it from https://cli.github.com, then authenticate:
  gh auth login --scopes project,repo

EOF
  exit 2
fi

if ! gh auth status &>/dev/null; then
  cat >&2 <<EOF
❌  gh CLI is not authenticated.

Run:  gh auth login --scopes project,repo

EOF
  exit 2
fi

# ── Resolve owner ─────────────────────────────────────────────
if [[ -z "$OWNER" ]]; then
  # Try to detect from the current repo remote
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
  if [[ -n "$REPO" ]]; then
    OWNER="${REPO%%/*}"
  else
    OWNER="@me"
  fi
fi

BODY=$(cat "$BODY_FILE")

# ── Dry run ───────────────────────────────────────────────────
if $DRY_RUN; then
  echo "════════════════════════════════════════"
  echo "  DRY RUN — nothing will be created"
  echo "════════════════════════════════════════"
  if [[ "$PROJECT_NUMBER" != "0" ]]; then
    echo "  Mode:    Draft item on project #$PROJECT_NUMBER"
  else
    echo "  Mode:    GitHub Issue (no project number supplied)"
  fi
  echo "  Owner:   $OWNER"
  echo "  Title:   $TITLE"
  [[ -n "$ASSIGNEE" ]] && echo "  Assignee: $ASSIGNEE"
  [[ -n "$PRIORITY" ]] && echo "  Priority: $PRIORITY"
  [[ -n "$SIZE"     ]] && echo "  Size:     $SIZE"
  echo "── Body ────────────────────────────────"
  cat "$BODY_FILE"
  echo "────────────────────────────────────────"
  exit 0
fi

# ─────────────────────────────────────────────────────────────
# Helper: set project item fields after creation
# Args: $1=item_id  $2=project_node_id  $3=fields_json
# ─────────────────────────────────────────────────────────────
set_project_fields() {
  local ITEM_ID="$1"
  local PROJECT_NODE_ID="$2"
  local FIELDS_JSON="$3"

  # ── Priority ──────────────────────────────────────────────
  if [[ -n "$PRIORITY" ]]; then
    python3 - <<PYEOF
import json, subprocess, sys

try:
    data = json.loads('''$FIELDS_JSON''')
    item_id = "$ITEM_ID"
    proj_id = "$PROJECT_NODE_ID"
    want    = "$PRIORITY".lower()

    for f in data.get('fields', []):
        if f['name'].lower() == 'priority':
            for opt in f.get('options', []):
                if opt['name'].lower() == want:
                    r = subprocess.run([
                        'gh', 'project', 'item-edit',
                        '--id', item_id,
                        '--project-id', proj_id,
                        '--field-id', f['id'],
                        '--single-select-option-id', opt['id']
                    ], capture_output=True, text=True)
                    if r.returncode == 0:
                        print(f"  ✓ Priority → {opt['name']}")
                    else:
                        print(f"  ⚠ Priority set failed: {r.stderr.strip()}", file=sys.stderr)
                    sys.exit(0)
except Exception as e:
    print(f"  ⚠ Priority: {e}", file=sys.stderr)
PYEOF
  fi

  # ── Size ──────────────────────────────────────────────────
  if [[ -n "$SIZE" ]]; then
    python3 - <<PYEOF
import json, subprocess, sys

try:
    data = json.loads('''$FIELDS_JSON''')
    item_id = "$ITEM_ID"
    proj_id = "$PROJECT_NODE_ID"
    want    = "$SIZE".lower()

    for f in data.get('fields', []):
        if f['name'].lower() == 'size':
            for opt in f.get('options', []):
                if opt['name'].lower() == want:
                    r = subprocess.run([
                        'gh', 'project', 'item-edit',
                        '--id', item_id,
                        '--project-id', proj_id,
                        '--field-id', f['id'],
                        '--single-select-option-id', opt['id']
                    ], capture_output=True, text=True)
                    if r.returncode == 0:
                        print(f"  ✓ Size → {opt['name']}")
                    else:
                        print(f"  ⚠ Size set failed: {r.stderr.strip()}", file=sys.stderr)
                    sys.exit(0)
except Exception as e:
    print(f"  ⚠ Size: {e}", file=sys.stderr)
PYEOF
  fi

  # ── Assignee (draft issue GraphQL mutation) ────────────────
  if [[ -n "$ASSIGNEE" ]]; then
    # 1. Resolve the user's global node ID
    USER_NODE_ID=$(gh api graphql \
      -f query="query { user(login: \"$ASSIGNEE\") { id } }" \
      -q '.data.user.id' 2>/dev/null || true)

    if [[ -z "$USER_NODE_ID" ]]; then
      echo "  ⚠ Assignee: could not resolve user '$ASSIGNEE' — skipping" >&2
    else
      # 2. Get the draft issue content ID from the project item
      DRAFT_ID=$(gh api graphql \
        -f query="query {
          node(id: \"$ITEM_ID\") {
            ... on ProjectV2Item {
              content { ... on DraftIssue { id } }
            }
          }
        }" \
        -q '.data.node.content.id' 2>/dev/null || true)

      if [[ -n "$DRAFT_ID" ]]; then
        # 3. Assign via updateProjectV2DraftIssue
        ASSIGN_RESULT=$(gh api graphql \
          -f query="mutation {
            updateProjectV2DraftIssue(input: {
              draftIssueId: \"$DRAFT_ID\"
              assigneeIds: [\"$USER_NODE_ID\"]
            }) {
              draftIssue { assignees(first: 5) { nodes { login } } }
            }
          }" 2>/dev/null || true)

        if echo "$ASSIGN_RESULT" | grep -q "\"login\""; then
          echo "  ✓ Assignee → $ASSIGNEE"
        else
          echo "  ⚠ Assignee set failed — set manually" >&2
        fi
      else
        echo "  ⚠ Assignee: item is not a draft issue — set manually" >&2
      fi
    fi
  fi
}

# ─────────────────────────────────────────────────────────────
# PATH A — Direct draft item on GitHub Projects v2 board
# ─────────────────────────────────────────────────────────────
if [[ "$PROJECT_NUMBER" != "0" ]]; then
  echo "Adding draft item to GitHub Project #$PROJECT_NUMBER (owner: $OWNER)..."

  RESULT=$(gh project item-create "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --title "$TITLE" \
    --body  "$BODY"  \
    --format json 2>&1) || {
    echo "❌  Failed to create project item." >&2
    echo "    Error: $RESULT"                  >&2
    echo ""                                    >&2
    echo "    Common fixes:"                   >&2
    echo "    • Refresh project scope:  gh auth refresh --scopes project" >&2
    echo "    • Verify project exists:  gh project list --owner $OWNER"   >&2
    exit 4
  }

  ITEM_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('url',''))" 2>/dev/null || true)
  ITEM_ID=$(echo "$RESULT"  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))"  2>/dev/null || true)

  echo "✓  Draft item added to project #$PROJECT_NUMBER"
  [[ -n "$ITEM_URL" ]] && echo "   $ITEM_URL"

  # ── Set project fields (Priority, Size, Assignee) ──────────
  if [[ -n "$ITEM_ID" ]] && { [[ -n "$PRIORITY" ]] || [[ -n "$SIZE" ]] || [[ -n "$ASSIGNEE" ]]; }; then
    PROJECT_NODE_ID=$(gh project view "$PROJECT_NUMBER" \
      --owner "$OWNER" --format json \
      -q '.id' 2>/dev/null || true)

    FIELDS_JSON=$(gh project field-list "$PROJECT_NUMBER" \
      --owner "$OWNER" --format json 2>/dev/null || true)

    if [[ -n "$PROJECT_NODE_ID" && -n "$FIELDS_JSON" ]]; then
      set_project_fields "$ITEM_ID" "$PROJECT_NODE_ID" "$FIELDS_JSON"
    else
      echo "  ⚠ Could not fetch project fields — Priority/Size/Assignee not set" >&2
    fi
  fi

  echo ""
  echo "PROJECT_ITEM_URL=$ITEM_URL"
  exit 0
fi

# ─────────────────────────────────────────────────────────────
# PATH B — Fallback: GitHub Issue (no project number given)
# ─────────────────────────────────────────────────────────────
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [[ -z "$REPO" ]]; then
  cat >&2 <<EOF
❌  --project-number was not supplied and no GitHub repo was detected.

Either:
  • Set project_number in .gang/config.yaml, or
  • Run from inside a GitHub repository directory

EOF
  exit 3
fi

echo "No project number supplied — creating GitHub Issue in $REPO..."

# Ensure label exists
gh label create "$LABEL" \
  --color "6e40c9" \
  --description "Gang multi-agent committee evaluation" \
  --repo "$REPO" 2>/dev/null || true

GH_ARGS=("issue" "create"
  --title "$TITLE"
  --body-file "$BODY_FILE"
  --label "$LABEL")
[[ -n "$MILESTONE" ]] && GH_ARGS+=(--milestone "$MILESTONE")

ISSUE_URL=$(gh "${GH_ARGS[@]}" 2>&1) || {
  echo "❌  Failed to create issue: $ISSUE_URL" >&2; exit 4
}

echo "✓  Issue created: $ISSUE_URL"
echo ""
echo "ISSUE_URL=$ISSUE_URL"
