#!/bin/bash
# Validate Gang workspace structure, schemas, and cross-references
# Usage: validate-gang.sh [output_root]
# Exit: 0 = all pass, 1 = failures found
set -uo pipefail

OUTPUT_ROOT="${1:-.gang}"
ERRORS=0
WARNINGS=0
CHECKS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() {
  CHECKS=$((CHECKS + 1))
  echo -e "  ${GREEN}[PASS]${NC} $1"
}

fail() {
  CHECKS=$((CHECKS + 1))
  ERRORS=$((ERRORS + 1))
  echo -e "  ${RED}[FAIL]${NC} $1"
}

warn() {
  CHECKS=$((CHECKS + 1))
  WARNINGS=$((WARNINGS + 1))
  echo -e "  ${YELLOW}[WARN]${NC} $1"
}

echo "Gang Validation Report"
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Output root: $OUTPUT_ROOT"
echo ""

# ─── 1. File Presence ──────────────────────────────────────
echo "1. File Presence"

# Required files
for f in state.json; do
  if [[ -f "$OUTPUT_ROOT/$f" ]]; then
    pass "$f exists"
  else
    fail "$f missing"
  fi
done

# Optional but expected files
for f in evidence.json assumptions.json context-brief.md competitive-scan.md; do
  if [[ -f "$OUTPUT_ROOT/$f" ]]; then
    pass "$f exists"
  else
    warn "$f missing"
  fi
done

echo ""

# ─── 2. JSON Validity ─────────────────────────────────────
echo "2. JSON Validity"

for f in state.json evidence.json assumptions.json; do
  if [[ -f "$OUTPUT_ROOT/$f" ]]; then
    if jq empty "$OUTPUT_ROOT/$f" 2>/dev/null; then
      pass "$f is valid JSON"
    else
      fail "$f is not valid JSON"
    fi
  fi
done

# Score rubric
if [[ -f "$OUTPUT_ROOT/score-rubric.json" ]]; then
  if jq empty "$OUTPUT_ROOT/score-rubric.json" 2>/dev/null; then
    pass "score-rubric.json is valid JSON"
  else
    fail "score-rubric.json is not valid JSON"
  fi
fi

echo ""

# ─── 3. State Schema Checks ───────────────────────────────
echo "3. State Schema"

if [[ -f "$OUTPUT_ROOT/state.json" ]]; then
  # Check required fields
  for field in version session_id started_at stages_completed current_stage; do
    if jq -e ".$field" "$OUTPUT_ROOT/state.json" >/dev/null 2>&1; then
      pass "state.json has '$field'"
    else
      fail "state.json missing '$field'"
    fi
  done

  # Check current_stage is valid
  STAGE=$(jq -r '.current_stage' "$OUTPUT_ROOT/state.json" 2>/dev/null)
  if echo "init think debate score advise deliver complete" | grep -qw "$STAGE"; then
    pass "state.json current_stage='$STAGE' is valid"
  else
    fail "state.json current_stage='$STAGE' is invalid"
  fi
fi

echo ""

# ─── 4. Evidence Schema Checks ────────────────────────────
echo "4. Evidence Ledger"

if [[ -f "$OUTPUT_ROOT/evidence.json" ]]; then
  COUNT=$(jq 'length' "$OUTPUT_ROOT/evidence.json" 2>/dev/null || echo 0)
  pass "evidence.json has $COUNT entries"

  # Check IDs follow pattern
  BAD_IDS=$(jq -r '.[].id // "missing"' "$OUTPUT_ROOT/evidence.json" 2>/dev/null | grep -cv '^ev-[0-9]\{3,\}$' || true)
  if [[ "$BAD_IDS" -eq 0 ]]; then
    pass "All evidence IDs match ev-NNN pattern"
  else
    fail "$BAD_IDS evidence entries have invalid IDs"
  fi

  # Check required fields
  MISSING=$(jq '[.[] | select(.id == null or .source == null or .text == null or .confidence == null)] | length' "$OUTPUT_ROOT/evidence.json" 2>/dev/null || echo 0)
  if [[ "$MISSING" -eq 0 ]]; then
    pass "All evidence entries have required fields"
  else
    fail "$MISSING evidence entries missing required fields"
  fi
fi

echo ""

# ─── 5. Assumptions Schema Checks ─────────────────────────
echo "5. Assumptions Ledger"

if [[ -f "$OUTPUT_ROOT/assumptions.json" ]]; then
  COUNT=$(jq 'length' "$OUTPUT_ROOT/assumptions.json" 2>/dev/null || echo 0)
  pass "assumptions.json has $COUNT entries"

  # Check IDs follow pattern
  BAD_IDS=$(jq -r '.[].id // "missing"' "$OUTPUT_ROOT/assumptions.json" 2>/dev/null | grep -cv '^as-[0-9]\{3,\}$' || true)
  if [[ "$BAD_IDS" -eq 0 ]]; then
    pass "All assumption IDs match as-NNN pattern"
  else
    fail "$BAD_IDS assumption entries have invalid IDs"
  fi

  # Check critical assumptions have validation plans
  MISSING_PLANS=$(jq '[.[] | select(.importance == "critical" and (.validation_plan == null or .validation_plan == ""))] | length' "$OUTPUT_ROOT/assumptions.json" 2>/dev/null || echo 0)
  if [[ "$MISSING_PLANS" -eq 0 ]]; then
    pass "All critical assumptions have validation plans"
  else
    fail "$MISSING_PLANS critical assumptions missing validation plans"
  fi
fi

echo ""

# ─── 6. Cross-Reference Checks ────────────────────────────
echo "6. Cross-References"

if [[ -d "$OUTPUT_ROOT/position-papers" ]]; then
  # Collect all evidence IDs
  EVIDENCE_IDS=""
  if [[ -f "$OUTPUT_ROOT/evidence.json" ]]; then
    EVIDENCE_IDS=$(jq -r '.[].id' "$OUTPUT_ROOT/evidence.json" 2>/dev/null | tr '\n' '|')
  fi

  # Check evidence_ids in position papers reference real entries
  if [[ -n "$EVIDENCE_IDS" ]]; then
    BAD_REFS=0
    for paper in "$OUTPUT_ROOT"/position-papers/*.md; do
      [[ -f "$paper" ]] || continue
      # Extract ev-NNN references from markdown
      REFS=$(grep -oP 'ev-\d{3,}' "$paper" 2>/dev/null || true)
      for ref in $REFS; do
        if ! echo "$EVIDENCE_IDS" | grep -q "$ref"; then
          BAD_REFS=$((BAD_REFS + 1))
          warn "$(basename "$paper"): references $ref which doesn't exist in evidence.json"
        fi
      done
    done
    if [[ "$BAD_REFS" -eq 0 ]]; then
      pass "All evidence references in position papers are valid"
    fi
  fi

  # Collect all assumption IDs
  ASSUMPTION_IDS=""
  if [[ -f "$OUTPUT_ROOT/assumptions.json" ]]; then
    ASSUMPTION_IDS=$(jq -r '.[].id' "$OUTPUT_ROOT/assumptions.json" 2>/dev/null | tr '\n' '|')
  fi

  if [[ -n "$ASSUMPTION_IDS" ]]; then
    BAD_REFS=0
    for paper in "$OUTPUT_ROOT"/position-papers/*.md; do
      [[ -f "$paper" ]] || continue
      REFS=$(grep -oP 'as-\d{3,}' "$paper" 2>/dev/null || true)
      for ref in $REFS; do
        if ! echo "$ASSUMPTION_IDS" | grep -q "$ref"; then
          BAD_REFS=$((BAD_REFS + 1))
          warn "$(basename "$paper"): references $ref which doesn't exist in assumptions.json"
        fi
      done
    done
    if [[ "$BAD_REFS" -eq 0 ]]; then
      pass "All assumption references in position papers are valid"
    fi
  fi
fi

echo ""

# ─── 7. Stage-Specific File Checks ────────────────────────
echo "7. Stage-Specific Files"

if [[ -f "$OUTPUT_ROOT/state.json" ]]; then
  STAGES=$(jq -r '.stages_completed[]' "$OUTPUT_ROOT/state.json" 2>/dev/null)

  for stage in $STAGES; do
    case "$stage" in
      init)
        [[ -f "$OUTPUT_ROOT/context-brief.md" ]] && pass "INIT: context-brief.md" || fail "INIT: context-brief.md missing"
        ;;
      think)
        PAPERS=$(find "$OUTPUT_ROOT/position-papers" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        [[ "$PAPERS" -gt 0 ]] && pass "THINK: $PAPERS position papers" || fail "THINK: no position papers"
        ;;
      debate)
        R1=$(find "$OUTPUT_ROOT/debate/round-1" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        [[ "$R1" -gt 0 ]] && pass "DEBATE: $R1 round-1 reviews" || fail "DEBATE: no round-1 reviews"
        [[ -f "$OUTPUT_ROOT/debate-log.md" ]] && pass "DEBATE: debate-log.md" || warn "DEBATE: debate-log.md missing"
        ;;
      score)
        [[ -f "$OUTPUT_ROOT/scored-plans.md" ]] && pass "SCORE: scored-plans.md" || fail "SCORE: scored-plans.md missing"
        ;;
      advise)
        [[ -f "$OUTPUT_ROOT/executive-brief.md" ]] && pass "ADVISE: executive-brief.md" || fail "ADVISE: executive-brief.md missing"
        ;;
      deliver)
        DOCS=$(find "$OUTPUT_ROOT/go-package" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
        [[ "$DOCS" -gt 0 ]] && pass "DELIVER: $DOCS go-package docs" || fail "DELIVER: no go-package docs"
        ;;
    esac
  done
fi

echo ""

# ─── 8. Required Sections in Position Papers ──────────────
echo "8. Position Paper Sections"

if [[ -d "$OUTPUT_ROOT/position-papers" ]]; then
  for paper in "$OUTPUT_ROOT"/position-papers/*.md; do
    [[ -f "$paper" ]] || continue
    NAME=$(basename "$paper")
    if grep -q "## Bottom Line" "$paper" 2>/dev/null; then
      pass "$NAME has '## Bottom Line'"
    else
      fail "$NAME missing '## Bottom Line' section"
    fi
  done
fi

echo ""

# ─── Summary ──────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Checks: $CHECKS | Passed: $((CHECKS - ERRORS - WARNINGS)) | Failed: $ERRORS | Warnings: $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
  echo -e "${RED}VALIDATION FAILED${NC}"
  exit 1
else
  echo -e "${GREEN}VALIDATION PASSED${NC}"
  exit 0
fi
