#!/bin/bash
# External provider dispatch for Gang committee agents
# Routes agent prompts to Perplexity, Gemini, or GitHub Copilot via API
#
# Usage: external-dispatch.sh --provider <name> --model <model> --input <prompt_file> --output <output_file>
#
# Exit codes:
#   0  — Success, output file written
#   10 — Provider unavailable (network error, auth failure)
#   11 — Malformed response (non-JSON, wrong structure)
#   12 — Timeout
#   13 — Rate limited
set -uo pipefail

PROVIDER=""
MODEL=""
INPUT_FILE=""
OUTPUT_FILE=""
TIMEOUT=120

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider) PROVIDER="$2"; shift 2 ;;
    --model)    MODEL="$2"; shift 2 ;;
    --input)    INPUT_FILE="$2"; shift 2 ;;
    --output)   OUTPUT_FILE="$2"; shift 2 ;;
    --timeout)  TIMEOUT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Validate required arguments
if [[ -z "$PROVIDER" || -z "$MODEL" || -z "$INPUT_FILE" || -z "$OUTPUT_FILE" ]]; then
  echo "Error: --provider, --model, --input, and --output are required" >&2
  exit 10
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file not found: $INPUT_FILE" >&2
  exit 10
fi

PROMPT=$(cat "$INPUT_FILE")

# ─── Perplexity (sonar-pro) ────────────────────────────────
dispatch_perplexity() {
  local api_key="${PERPLEXITY_API_KEY:-}"
  if [[ -z "$api_key" ]]; then
    echo "Error: PERPLEXITY_API_KEY not set" >&2
    return 10
  fi

  local response
  local http_code
  local tmp_file
  tmp_file=$(mktemp)

  http_code=$(curl -s -w "%{http_code}" -o "$tmp_file" \
    --max-time "$TIMEOUT" \
    -X POST "https://api.perplexity.ai/chat/completions" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" '{
      model: $model,
      messages: [
        { role: "system", content: "You are a senior business analyst. Produce thorough, evidence-backed analysis." },
        { role: "user", content: $prompt }
      ],
      max_tokens: 4096,
      temperature: 0.3
    }')" 2>/dev/null)

  case "$http_code" in
    200)
      # Extract content from response
      local content
      content=$(jq -r '.choices[0].message.content // empty' "$tmp_file" 2>/dev/null)
      if [[ -z "$content" ]]; then
        rm -f "$tmp_file"
        echo "Error: Empty or malformed response from Perplexity" >&2
        return 11
      fi
      echo "$content" > "$OUTPUT_FILE"
      rm -f "$tmp_file"
      return 0
      ;;
    401|403)
      rm -f "$tmp_file"
      echo "Error: Perplexity auth failure (HTTP $http_code)" >&2
      return 10
      ;;
    429)
      rm -f "$tmp_file"
      echo "Error: Perplexity rate limited" >&2
      return 13
      ;;
    000)
      rm -f "$tmp_file"
      echo "Error: Perplexity timeout or network error" >&2
      return 12
      ;;
    *)
      rm -f "$tmp_file"
      echo "Error: Perplexity HTTP $http_code" >&2
      return 10
      ;;
  esac
}

# ─── Gemini (gemini-2.5-pro) ───────────────────────────────
dispatch_gemini() {
  local api_key="${GEMINI_API_KEY:-}"
  if [[ -z "$api_key" ]]; then
    echo "Error: GEMINI_API_KEY not set" >&2
    return 10
  fi

  local http_code
  local tmp_file
  tmp_file=$(mktemp)

  http_code=$(curl -s -w "%{http_code}" -o "$tmp_file" \
    --max-time "$TIMEOUT" \
    -X POST "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${api_key}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg prompt "$PROMPT" '{
      contents: [{ parts: [{ text: $prompt }] }],
      generationConfig: {
        temperature: 0.3,
        maxOutputTokens: 8192
      }
    }')" 2>/dev/null)

  case "$http_code" in
    200)
      local content
      content=$(jq -r '.candidates[0].content.parts[0].text // empty' "$tmp_file" 2>/dev/null)
      if [[ -z "$content" ]]; then
        rm -f "$tmp_file"
        echo "Error: Empty or malformed response from Gemini" >&2
        return 11
      fi
      echo "$content" > "$OUTPUT_FILE"
      rm -f "$tmp_file"
      return 0
      ;;
    401|403)
      rm -f "$tmp_file"
      echo "Error: Gemini auth failure (HTTP $http_code)" >&2
      return 10
      ;;
    429)
      rm -f "$tmp_file"
      echo "Error: Gemini rate limited" >&2
      return 13
      ;;
    000)
      rm -f "$tmp_file"
      echo "Error: Gemini timeout or network error" >&2
      return 12
      ;;
    *)
      rm -f "$tmp_file"
      echo "Error: Gemini HTTP $http_code" >&2
      return 10
      ;;
  esac
}

# ─── GitHub Copilot / OpenAI-compatible (gpt-4o) ──────────
dispatch_copilot() {
  local api_key="${GITHUB_TOKEN:-}"
  if [[ -z "$api_key" ]]; then
    echo "Error: GITHUB_TOKEN not set" >&2
    return 10
  fi

  local http_code
  local tmp_file
  tmp_file=$(mktemp)

  http_code=$(curl -s -w "%{http_code}" -o "$tmp_file" \
    --max-time "$TIMEOUT" \
    -X POST "https://models.inference.ai.azure.com/chat/completions" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" '{
      model: $model,
      messages: [
        { role: "system", content: "You are a senior business analyst. Produce thorough, evidence-backed analysis." },
        { role: "user", content: $prompt }
      ],
      max_tokens: 4096,
      temperature: 0.3
    }')" 2>/dev/null)

  case "$http_code" in
    200)
      local content
      content=$(jq -r '.choices[0].message.content // empty' "$tmp_file" 2>/dev/null)
      if [[ -z "$content" ]]; then
        rm -f "$tmp_file"
        echo "Error: Empty or malformed response from Copilot" >&2
        return 11
      fi
      echo "$content" > "$OUTPUT_FILE"
      rm -f "$tmp_file"
      return 0
      ;;
    401|403)
      rm -f "$tmp_file"
      echo "Error: Copilot auth failure (HTTP $http_code)" >&2
      return 10
      ;;
    429)
      rm -f "$tmp_file"
      echo "Error: Copilot rate limited" >&2
      return 13
      ;;
    000)
      rm -f "$tmp_file"
      echo "Error: Copilot timeout or network error" >&2
      return 12
      ;;
    *)
      rm -f "$tmp_file"
      echo "Error: Copilot HTTP $http_code" >&2
      return 10
      ;;
  esac
}

# ─── Dispatch Router ───────────────────────────────────────
case "$PROVIDER" in
  perplexity) dispatch_perplexity; exit $? ;;
  gemini)     dispatch_gemini; exit $? ;;
  copilot)    dispatch_copilot; exit $? ;;
  *)
    echo "Error: Unknown provider '$PROVIDER'. Supported: perplexity, gemini, copilot" >&2
    exit 10
    ;;
esac
