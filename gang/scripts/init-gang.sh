#!/bin/bash
# Initialize Gang workspace in the current project directory
# Usage: init-gang.sh [--type flat|feature|project] [--name <slug>]
set -euo pipefail

GANG_DIR=".gang"
EVAL_TYPE="flat"
EVAL_NAME=""
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      EVAL_TYPE="$2"
      shift 2
      ;;
    --name)
      EVAL_NAME="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Determine output root based on evaluation type
case "$EVAL_TYPE" in
  feature)
    if [[ -z "$EVAL_NAME" ]]; then
      echo "Error: --name required for feature evaluation" >&2
      exit 1
    fi
    OUTPUT_ROOT="$GANG_DIR/features/$EVAL_NAME"
    ;;
  project)
    if [[ -z "$EVAL_NAME" ]]; then
      echo "Error: --name required for project evaluation" >&2
      exit 1
    fi
    OUTPUT_ROOT="$GANG_DIR/projects/$EVAL_NAME"
    ;;
  flat|*)
    OUTPUT_ROOT="$GANG_DIR"
    ;;
esac

# Create top-level .gang directories (always needed)
mkdir -p "$GANG_DIR/features"
mkdir -p "$GANG_DIR/projects"
mkdir -p "$GANG_DIR/learnings"

# Create evaluation-specific directory structure
mkdir -p "$OUTPUT_ROOT/position-papers"
mkdir -p "$OUTPUT_ROOT/debate/round-1"
mkdir -p "$OUTPUT_ROOT/debate/round-2"
mkdir -p "$OUTPUT_ROOT/ux-deliverables"
mkdir -p "$OUTPUT_ROOT/go-package"

# Copy default config if it doesn't exist
if [[ ! -f "$GANG_DIR/config.yaml" ]]; then
  if [[ -f "$PLUGIN_ROOT/skills/gang/references/default-config.yaml" ]]; then
    cp "$PLUGIN_ROOT/skills/gang/references/default-config.yaml" "$GANG_DIR/config.yaml"
  fi
fi

# Copy default score rubric to output root
if [[ ! -f "$OUTPUT_ROOT/score-rubric.json" ]]; then
  if [[ -f "$PLUGIN_ROOT/skills/gang/references/default-score-rubric.json" ]]; then
    cp "$PLUGIN_ROOT/skills/gang/references/default-score-rubric.json" "$OUTPUT_ROOT/score-rubric.json"
  fi
fi

# Initialize empty evidence.json
if [[ ! -f "$OUTPUT_ROOT/evidence.json" ]]; then
  echo "[]" > "$OUTPUT_ROOT/evidence.json"
fi

# Initialize empty assumptions.json
if [[ ! -f "$OUTPUT_ROOT/assumptions.json" ]]; then
  echo "[]" > "$OUTPUT_ROOT/assumptions.json"
fi

# Generate session ID
if command -v uuidgen &>/dev/null; then
  SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else
  SESSION_ID="gang-$(date +%Y%m%d-%H%M%S)"
fi

# Get current timestamp
STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize state file
cat > "$OUTPUT_ROOT/state.json" << EOF
{
  "version": "1.3.0",
  "session_id": "$SESSION_ID",
  "started_at": "$STARTED_AT",
  "stages_completed": [],
  "current_stage": "init",
  "evaluation_type": "$EVAL_TYPE",
  "evaluation_name": "$EVAL_NAME",
  "output_root": "$OUTPUT_ROOT",
  "brief": "$OUTPUT_ROOT/context-brief.md",
  "domain_expert_enabled": false,
  "active_agents": [],
  "debate_mode": "all-vs-all",
  "debate_matrix": {},
  "agent_results": {},
  "cost": {
    "total_estimated_usd": 0.00,
    "budget_limit": 0,
    "stages": {
      "init": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00 },
      "think": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00, "by_agent": {} },
      "debate": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00, "by_agent": {} },
      "score": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00 },
      "advise": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00 },
      "deliver": { "tokens_in": 0, "tokens_out": 0, "estimated_usd": 0.00 }
    }
  },
  "reinit_count": 0,
  "last_reinit": null
}
EOF

echo "Gang workspace initialized at $OUTPUT_ROOT (session: $SESSION_ID, type: $EVAL_TYPE)"
