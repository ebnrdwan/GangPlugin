<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-7C3AED?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMyA3djEwbDkgNSA5LTVWN2wtOS01eiIgZmlsbD0id2hpdGUiLz48L3N2Zz4=" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/version-1.3.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/agents-9_configurable-orange?style=for-the-badge" alt="Agents">
  <img src="https://img.shields.io/badge/features-11-brightgreen?style=for-the-badge" alt="Features">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
  <br><br>
  <a href="https://ebnrdwan.github.io/GangPlugin/">
    <img src="https://img.shields.io/badge/⚡_Animated_Overview-View_Live-7C3AED?style=for-the-badge" alt="Animated Overview">
  </a>
</p>

<h1 align="center">Gang</h1>
<h3 align="center">Configurable Multi-Agent Business Committee for Claude Code</h3>

<p align="center">
  <strong>One command. Configurable experts. Evidence-backed verdict.</strong><br/>
  Turn your IDE into a boardroom — configure which experts analyze, how they debate, what budget they use,<br/>
  and get a rubric-anchored Go/No-Go recommendation with full audit trail.
</p>

<p align="center">
  <code>/gang run</code>
</p>

---

## What's New in v1.3.0

| Feature | Description |
|---------|-------------|
| **Role Controls** | Enable/disable agents, set weight (light/deep), model (haiku/sonnet/opus), timeout |
| **Selective Debate** | 4 debate modes: all-vs-all, selective pairs, relevance-based, focused topics |
| **Output Organization** | Save evaluations by feature or project in organized folders |
| **Cost Management** | Token estimation, budget limits, warnings, auto-blocking |
| **Adaptive Model Routing** | Budget-adaptive downgrade (opus->sonnet->haiku) + multi-provider (Perplexity, Gemini, Copilot) |
| **Evidence Ledger** | Codebase scan + web research populate evidence.json; agents must cite evidence_ids |
| **Assumptions Ledger** | Agents register unstated hypotheses with validation plans |
| **Scoring Rubrics** | Rubric-anchored scores (1-10 with textual descriptions per level) |
| **Advisor Guardrails** | CEO/CTO can't issue GO without rubric-anchored scores; auto-CONDITIONAL-GO on unvalidated assumptions |
| **Validation Layer** | Schema validation, cross-reference checks, between-stage validation, CI integration |
| **Quality Mode Presets** | Quick Scout ($~1) / Product Review ($~5) / Investment Grade ($~20) |

---

## Quick Start

```bash
# 1. Install the plugin
claude plugin install https://github.com/ebnrdwan/GangPlugin

# 2. Run on any project
/gang run
```

---

## How It Works

```mermaid
graph LR
    A["INIT<br/>Scan + Evidence"] --> B["THINK<br/>Committee Setup + Experts"]
    B --> C["DEBATE<br/>Configurable Rounds"]
    C --> D["SCORE<br/>Rubric-Anchored"]
    D --> E["ADVISE<br/>Guardrailed Verdict"]
    E --> F["DELIVER<br/>GO Package"]

    style A fill:#6366f1,stroke:#4f46e5,color:#fff
    style B fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style C fill:#a855f7,stroke:#9333ea,color:#fff
    style D fill:#c084fc,stroke:#a855f7,color:#fff
    style E fill:#d946ef,stroke:#c026d3,color:#fff
    style F fill:#f97316,stroke:#ea580c,color:#fff
```

### Stage Pipeline

| Stage | What Happens |
|-------|-------------|
| **INIT** | Deep project scan, evidence population (codebase + web research), competitive research, quality mode selection |
| **THINK** | Committee setup question (every time), parallel expert dispatch with evidence/assumptions protocol |
| **DEBATE** | Configurable debate mode (4 options), evidence-cited critiques, 1-2 rounds |
| **SCORE** | Rubric-anchored scoring with evidence linking, weighted averages, confidence levels |
| **ADVISE** | CEO/CTO advisory with guardrails — auto-conditional on unvalidated assumptions |
| **DELIVER** | BRD, technical architecture, project charter, risk register, data model, API contracts |

### Status Display (v1.3.0)

```
Gang Committee Status
━━━━━━━━━━━━━━━━━━━━━━━━
Session: gang-20260330-143022
Version: 1.3.0
Mode: product_review
Evaluation: feature — stock-details-page

Committee (5 active):
  [on]  PM Lead ............. deep (sonnet)
  [on]  Market Researcher ... deep (perplexity-sonar-pro)
  [off] UX Researcher ....... disabled
  [on]  Finance Analyst ..... deep (gemini-2.5-pro)
  [on]  Solutions Architect . deep (sonnet)
  [off] Business Strategist . disabled
  [off] Domain Expert ....... disabled
  [on]  CEO/CTO Advisor ..... deep (opus)

Debate: selective · 2 rounds
Evidence: 14 entries · 8 assumptions tracked
Validation: strict (passing)

[done] INIT ........... $0.12  validated
[done] THINK .......... $1.23  validated (5/5 agents, 0 failures)
[ -> ] DEBATE ......... in progress
[    ] SCORE
[    ] ADVISE
[    ] DELIVER

Cost: ~$1.35 / $5.00 budget (27%)

Next: Run /gang debate to continue
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/gang run` | Run full pipeline end-to-end |
| `/gang init` | Initialize workspace, select quality mode, scan project, populate evidence |
| `/gang think` | Committee setup + parallel expert analysis |
| `/gang debate` | Configurable cross-review debate |
| `/gang score` | Rubric-anchored plan synthesis and scoring |
| `/gang advise` | CEO/CTO advisory with guardrails |
| `/gang deliver` | Generate GO Package (requires GO/CONDITIONAL-GO) |
| `/gang reinit` | Re-run INIT, refresh context, reset downstream |
| `/gang status` | Show progress, committee, cost, validation |
| `/gang config` | Show/edit configuration |
| `/gang evaluations` | List all feature and project evaluations |
| `/gang validate` | Run validation checks |

---

## The Committee

| Expert | Focus | Model |
|--------|-------|-------|
| **PM Lead** | RICE, MVP scope, requirements | Configurable |
| **Market Researcher** | TAM/SAM/SOM, competitive analysis, SWOT | Configurable (Perplexity option) |
| **UX Researcher** | Personas, journeys, design tokens, Stitch specs | Configurable |
| **Finance/Risk Analyst** | DCF, SaaS metrics, risk matrix, scenarios | Configurable (Gemini option) |
| **Solutions Architect** | Feasibility, architecture, build-vs-buy TCO | Configurable (Copilot option) |
| **Business Strategist** | GTM, business model, competitive moat | Configurable (Gemini option) |
| **Domain Expert** *(optional)* | Industry SME — regulatory, benchmarks, domain risks | Configurable |
| **CEO/CTO Advisor** | Go/No-Go verdict, kill switches, roadmap | Opus (always last to downgrade) |
| **Deliverables Writer** | BRD, architecture, charter, risk register, data model, API contracts | Configurable |

---

## Quality Mode Presets

Selected at the start of every `/gang init`. Each preset writes a complete `config.yaml`.

| Mode | Agents | Weight | Estimated Cost | Debate | Routing | Best For |
|------|--------|--------|:--------------:|--------|---------|----------|
| **Quick Scout** | 3 (PM, Architect, CEO) | Light | ~$0.50–$1.50 | Focused, 1 round | Budget-adaptive | Early filtering |
| **Product Review** | 5 core + CEO | Deep | ~$2–$5 | Selective, 2 rounds | Budget-adaptive | Feature evaluation |
| **Investment Grade** | All 7–8 | Deep | ~$8–$20 | Relevance-based, 2 rounds | Multi-provider | Major decisions |
| **Custom** | You choose | You choose | You set | You configure | You choose | Full control |

> Costs vary based on project size (larger codebases = larger evidence files = higher input tokens) and number of competitors found.

---

## Configuration

All settings live in `.gang/config.yaml`. Edit between stages — changes take effect on the next stage run. View current settings with `/gang config`.

Key configuration areas:

| Area | What It Controls |
|------|-----------------|
| **Roles** | Enable/disable each agent, set weight (light = 500 words / deep = 1500+), model, timeout |
| **Debate** | Mode: `all-vs-all` / `selective` / `relevance-based` / `focused`; max rounds (1 or 2) |
| **Cost** | Budget limit (USD), `warn_at` % (default 80%), `block_at` % (default 100%), per-model rates |
| **Routing** | `manual` (explicit model per agent) / `budget-adaptive` (auto-downgrade at 60%/80% budget) / `multi-provider` (Perplexity, Gemini, Copilot) |
| **Evidence** | Require citation in claims, web research provider, fallback chain (perplexity → gemini → claude) |
| **Scoring** | Rubric anchoring required, evidence linking required, advisor guardrails (require_rubric_for_go, auto_conditional_on_unvalidated) |
| **Validation** | Strict (block) or relaxed (warn), between-stage checks, cross-reference validation |
| **Failure Handling** | Retry on failure, fallback to cheaper model, partial failure confidence degradation |

**Budget-adaptive routing** downgrades models as budget is consumed: at 60% opus→sonnet, at 80% sonnet→haiku. The CEO/CTO Advisor is always last to downgrade — it stays on Opus until maximum budget pressure.

**Multi-provider routing** sends specific agents to external providers: Market Researcher → Perplexity sonar-pro, Finance Analyst + Business Strategist → Gemini 2.5 Pro, Solutions Architect → GitHub Copilot (GPT-4o). Each has a Claude fallback on failure.

---

## Evidence & Assumptions

Every claim in the evaluation is either:
- **Evidence-backed** — cited from `evidence.json` (populated during INIT from codebase scan + web research). Agents must reference `evidence_ids: [ev-001, ev-012]` for every major claim.
- **Assumption-flagged** — registered in `assumptions.json` with an ID, importance level (critical/high/medium/low), and a validation plan stating how to test it.

**Advisor guardrails enforce this at verdict time:**
- Cannot issue GO without rubric-anchored scores on critical dimensions
- Cannot issue GO if critical/high-importance assumptions lack validation plans
- Auto-downgrades GO → CONDITIONAL-GO when critical assumptions are unvalidated — with explicit list of which assumptions must be validated to make the GO unconditional

These are hard constraints in the CEO/CTO Advisor's prompt, not just guidelines.

---

## Full Documentation

📖 **[Interactive Deep Dive →](https://ebnrdwan.github.io/GangPlugin/deep-dive.html)**

The deep dive page covers:
- Detailed breakdown of all 11 v1.3.0 features with config examples
- Token estimation formula and cost calculation examples
- Budget-adaptive downgrade priority table and worked scenarios
- External provider setup (Perplexity, Gemini, GitHub Copilot) with exit codes
- Evidence and assumptions JSON schemas with field-level docs
- Scoring rubric format (all 6 levels per dimension)
- Validation checks reference and CI integration
- Complete `config.yaml` reference with every setting and default

---

## License

MIT — use it, fork it, build on it.
