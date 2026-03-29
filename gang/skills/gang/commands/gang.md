---
description: "Run the Gang business committee — a panel of 6-7 domain experts that evaluates product ideas through structured debate, produces scored strategic plans, and delivers an executive Go/No-Go recommendation with Google Stitch-ready UI specs and build-ready deliverables. Subcommands: init, think, debate, score, advise, deliver, reinit, run, status."
argument-hint: "[init|think|debate|score|advise|deliver|reinit|run|status]"
---

# Gang Business Committee

You have been invoked as the Gang business committee orchestrator. Load and execute the `gang` skill which contains the full 5-stage workflow.

## Subcommand Routing

Parse the arguments provided by the user:

- **No arguments or `run`:** Execute the full 5-stage pipeline (INIT → THINK → DEBATE → SCORE → ADVISE)
- **`init`:** Run Stage 1 only — deep project scan, competitive research, domain expert opt-in, targeted questions, produce context brief
- **`think`:** Run Stage 2 only — dispatch 6-7 experts in parallel for independent analysis
- **`debate`:** Run Stage 3 only — 2 rounds of structured cross-review debate
- **`score`:** Run Stage 4 only — synthesize and score 1-2 competing plans
- **`advise`:** Run Stage 5 only — CEO/CTO advisory with Go/No-Go recommendation
- **`deliver`:** Generate GO Package — BRD, technical architecture, project charter, risk register, data model, API contracts (requires GO/CONDITIONAL-GO verdict)
- **`reinit`:** Re-run INIT on existing session — refreshes context brief, resets downstream stages, preserves session ID
- **`status`:** Show current progress and list generated artifacts

## Execution Rules

1. **Check prerequisites:** Before running any stage, verify that prerequisite stages are complete by reading `.gang/state.json`. If prerequisites are missing, inform the user which stages need to run first.

2. **Parallel dispatch:** In Stage 2 (THINK) and each debate round in Stage 3, dispatch ALL agents in a SINGLE message using parallel Agent tool calls. Do NOT dispatch them sequentially.

3. **Visibility:** After each stage completes, present a concise summary to the user showing what was produced and key findings. The user should see progress in real-time, not just a final dump.

4. **Interactive after Stage 5:** After the executive brief is delivered, enter Q&A mode. The user can ask follow-up questions about any aspect of the committee's findings.

5. **UX deliverables reminder:** After Stage 2, remind the user that Google Stitch instructions are available at `.gang/ux-deliverables/stitch-instructions.md`.

## Error Recovery

- If an agent fails, report which one and offer to retry just that agent
- If `.gang/` doesn't exist, run init first regardless of the subcommand
- If the user provides additional context after init, offer to update the context brief and re-run affected stages
