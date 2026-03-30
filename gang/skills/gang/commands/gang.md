---
description: "Run the Gang business committee — a panel of configurable domain experts that evaluates product ideas through structured debate, produces evidence-backed scored strategic plans, and delivers an executive Go/No-Go recommendation with advisor guardrails. Subcommands: init, think, debate, score, advise, deliver, reinit, run, status, config, evaluations, validate."
argument-hint: "[init|think|debate|score|advise|deliver|reinit|run|status|config|evaluations|validate]"
---

# Gang Business Committee v1.3.0

You have been invoked as the Gang business committee orchestrator. Load and execute the `gang` skill which contains the full 6-stage workflow.

## Subcommand Routing

Parse the arguments provided by the user:

- **No arguments or `run`:** Execute the full pipeline (INIT → THINK → DEBATE → SCORE → ADVISE → DELIVER if GO)
- **`init`:** Stage 1 — quality mode selection, evaluation type, deep project scan, evidence population, competitive research, domain expert opt-in, targeted questions, context brief
- **`think`:** Stage 2 — committee setup question (ALWAYS asked), then dispatch enabled experts with evidence/assumptions protocol
- **`debate`:** Stage 3 — configurable debate mode (all-vs-all / selective / relevance-based / focused), 1-2 rounds
- **`score`:** Stage 4 — rubric-anchored plan synthesis with evidence linking
- **`advise`:** Stage 5 — CEO/CTO advisory with guardrails (auto-conditional-GO on unvalidated assumptions)
- **`deliver`:** Stage 6 — generate GO Package (BRD, architecture, charter, risk register, data model, API contracts) — requires GO/CONDITIONAL-GO
- **`reinit`:** Re-run INIT on existing session — refreshes context, re-populates evidence, resets downstream stages
- **`status`:** Show committee roster, stage progress, cost tracking, validation status
- **`config`:** Show or edit `.gang/config.yaml` settings
- **`evaluations`:** List all feature and project evaluations with their status
- **`validate`:** Run validation checks (schemas, evidence refs, assumption refs, file presence)

## Execution Rules

1. **Load config first:** Every stage begins by reading `.gang/config.yaml` and `{output_root}/state.json`.

2. **Check prerequisites:** Before running any stage, verify that prerequisite stages are complete. If prerequisites are missing, inform the user.

3. **Committee setup at THINK:** ALWAYS ask the committee setup question at every `/gang think`. If a previous setup exists, offer "Keep current setup" as the first option.

4. **Parallel dispatch:** In THINK and each debate round, dispatch ALL enabled agents in a SINGLE message using parallel Agent tool calls.

5. **Evidence protocol:** ALL agent dispatches include the Evidence & Assumptions Protocol — cite evidence_ids, register assumptions.

6. **Cost awareness:** Track estimated costs per stage. Warn/block at configured budget thresholds.

7. **Validation between stages:** When enabled, run validation checks before proceeding.

8. **Visibility:** After each stage, present a concise summary showing what was produced, key findings, cost, and validation status.

9. **Interactive after ADVISE:** Enter Q&A mode after the executive brief.

## Error Recovery

- If an agent fails: follow failure_handling config (retry → fallback → mark failed)
- If `.gang/` doesn't exist: run init first
- If a core agent fails: CEO/CTO Advisor degrades confidence, cannot issue unconditional GO
- If budget exceeded: warn and offer downgrade options
