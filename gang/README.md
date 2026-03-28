# Gang — Multi-Agent Business Committee for Claude Code

A Claude Code plugin that orchestrates 6 domain experts through structured debate to evaluate product ideas and deliver executive-ready strategic recommendations.

## What It Does

Gang runs a 5-stage business committee:

```
1. INIT  →  2. THINK  →  3. DEBATE  →  4. SCORE  →  5. ADVISE
(Context     (6 experts    (Cross-       (1-2 scored   (Go/No-Go
 brief)       in parallel)  review)       plans)         verdict)
```

**Stage 1 — INIT:** Scans your project (if one exists), asks scoping questions, produces a context brief.

**Stage 2 — THINK:** 6 experts analyze independently in parallel:
- **PM Lead** — Scope, RICE prioritization, MVP definition
- **Market Researcher** — TAM/SAM/SOM, 12-dimension competitive scoring, SWOT
- **UX Researcher** — Personas, JTBD, journey maps, design tokens, Google Stitch instructions
- **Finance/Risk Analyst** — DCF valuation, SaaS metrics, risk matrix, scenario modeling
- **Solutions Architect** — Feasibility scoring, tech stack, build-vs-buy TCO, DORA metrics
- **Business Strategist** — Positioning, GTM strategy, business model canvas, competitive moat

**Stage 3 — DEBATE:** 2 rounds of structured cross-review using Board Meeting protocol + Executive Mentor adversarial challenges (pre-mortem, stress-test, kill switches).

**Stage 4 — SCORE:** Synthesizes 1-2 competing plans scored on 5 dimensions (market viability, user desirability, technical feasibility, financial viability, strategic alignment).

**Stage 5 — ADVISE:** CEO/CTO Advisor (Opus model) produces an 11-section executive brief with Go/No-Go recommendation, kill switches, downside scenarios, and implementation roadmap.

## Installation

```bash
# Local testing
claude plugin add /path/to/GangPlugin

# From marketplace (when published)
claude plugin add gang
```

## Usage

```bash
# Full 5-stage pipeline
/gang

# Or run stages individually
/gang init       # Context onboarding
/gang think      # Expert analysis
/gang debate     # Cross-review
/gang score      # Plan synthesis
/gang advise     # Executive recommendation
/gang status     # Check progress
```

## Output Artifacts

All output is written to `.gang/` in your project directory:

```
.gang/
├── state.json                    # Session state and progress
├── context-brief.md              # Stage 1 output
├── position-papers/              # Stage 2 output (6 files)
│   ├── gang-pm-lead.md
│   ├── gang-market-researcher.md
│   ├── gang-ux-researcher.md
│   ├── gang-finance-risk-analyst.md
│   ├── gang-solutions-architect.md
│   └── gang-business-strategist.md
├── ux-deliverables/              # Stage 2 UX output (9 files)
│   ├── personas.md
│   ├── jobs-to-be-done.md
│   ├── user-journeys.md
│   ├── information-architecture.md
│   ├── wireframes.md
│   ├── design-tokens.md
│   ├── interaction-patterns.md
│   ├── accessibility-notes.md
│   └── stitch-instructions.md   # Copy-paste into Google Stitch
├── debate/
│   ├── round-1/                  # Stage 3 critiques (6 files)
│   └── round-2/                  # Stage 3 revised positions (6 files)
├── debate-log.md                 # Stage 3 conflict summary
├── scored-plans.md               # Stage 4 scored plans
└── executive-brief.md            # Stage 5 final recommendation
```

## Google Stitch Integration

The UX Researcher produces `.gang/ux-deliverables/stitch-instructions.md` — a structured prompt file designed for Google Stitch. It includes:

- App overview and design direction
- Complete design system (OKLCH colors, typography, spacing, corners, shadows, motion)
- Screen-by-screen component layouts with realistic content examples
- Global UI patterns (navigation, loading, empty states, errors)
- Anti-pattern rules to prevent generic AI-generated UI

Copy the contents of `stitch-instructions.md` directly into Google Stitch to generate UI screens.

## Design Quality

All UX output follows [Impeccable](https://github.com/pbakaus/impeccable) design quality rules:
- No default fonts (Inter, Poppins, Montserrat blocked)
- OKLCH color space with tinted neutrals (never pure gray)
- 4px/8px spacing grid strictly enforced
- WCAG AA contrast ratios on all text
- 44px minimum touch targets on mobile
- Mandatory focus states, reduced-motion support

## Expert Frameworks

| Expert | Key Frameworks |
|--------|---------------|
| PM Lead | RICE (Reach x Impact x Confidence / Effort), MoSCoW, PRD templates |
| Market Researcher | 12-dimension competitive rubric, TAM/SAM/SOM, Porter's Five Forces, SWOT |
| UX Researcher | Personas, JTBD, journey mapping, Impeccable design rules, DSL layout |
| Finance/Risk | DCF valuation, SaaS metrics (ARR/MRR/churn/CAC/LTV/NRR), scenario modeling |
| Solutions Architect | Tech debt scoring, DORA metrics, build-vs-buy TCO, ADRs |
| Business Strategist | Business Model Canvas, GTM phases, competitive moat (Porter), pricing |
| CEO/CTO Advisor | Strategic options matrix, Tree of Thought, capital allocation, pre-mortem, stress-test, kill switches |

## Requirements

- Claude Code CLI
- No additional dependencies — the plugin is self-contained

## License

MIT
