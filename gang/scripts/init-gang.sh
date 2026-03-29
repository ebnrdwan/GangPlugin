#!/bin/bash
# Initialize Gang workspace in the current project directory
set -euo pipefail

GANG_DIR=".gang"

# Create directory structure
mkdir -p "$GANG_DIR/position-papers"
mkdir -p "$GANG_DIR/debate/round-1"
mkdir -p "$GANG_DIR/debate/round-2"
mkdir -p "$GANG_DIR/ux-deliverables"
mkdir -p "$GANG_DIR/go-package"
mkdir -p "$GANG_DIR/learnings"

# Generate session ID
if command -v uuidgen &>/dev/null; then
  SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
  SESSION_ID=$(date +%s)-$$
fi

# Get current timestamp
STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize state file
cat > "$GANG_DIR/state.json" << EOF
{
  "session_id": "$SESSION_ID",
  "started_at": "$STARTED_AT",
  "stages_completed": [],
  "current_stage": "init",
  "brief": ".gang/context-brief.md",
  "domain_expert_enabled": false
}
EOF

echo "Gang workspace initialized at $GANG_DIR (session: $SESSION_ID)"
