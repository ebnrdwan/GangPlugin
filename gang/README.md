# Gang — Multi-Agent Business Committee for Claude Code

> **One command. Six experts. One verdict.**
> Gang turns Claude Code into a boardroom — 6 domain experts independently analyze your product idea, debate each other's positions, and a CEO/CTO advisor delivers a scored Go/No-Go recommendation.

```
/gang run
```

---

## The Gap

Today's AI-assisted development is great at **building** — but terrible at deciding **what to build and why**.

| What exists today | What's missing |
|---|---|
| AI coding assistants that generate code fast | No structured framework to evaluate whether the code *should* be written |
| Single-perspective AI advice ("here's what I think") | Multi-perspective adversarial analysis that stress-tests assumptions |
| Product strategy tools that require manual input into 5 different SaaS platforms | One command that scans your codebase, researches competitors, and delivers a complete strategic analysis |
| Go/No-Go decisions made on gut feel in Slack threads | Quantified scoring across market viability, feasibility, finance, UX, and strategy — with kill switches |
| Design tools disconnected from business strategy | UX deliverables (personas, journeys, design tokens) that flow directly from strategic decisions into Google Stitch |
| Competitive analysis as a separate manual research task | Automated competitive scan built into the evaluation pipeline |

**The core problem:** Engineers ship features nobody asked for. Founders chase markets that don't exist. Teams build before validating. The cost isn't the code — it's the months spent building the wrong thing.

**Gang closes this gap** by embedding a structured business evaluation pipeline directly in your development environment — where the decisions actually happen.

---

## How It Works

```
    /gang init          /gang think          /gang debate         /gang score          /gang advise
        |                   |                    |                    |                    |
   +---------+      +-------------+      +-------------+      +----------+      +------------+
   |  SCAN   |      | 6 EXPERTS   |      | 2 ROUNDS    |      | SCORED   |      | CEO/CTO    |
   | project |  ->  | in parallel |  ->  | cross-      |  ->  | plans    |  ->  | Go/No-Go   |
   | + market|      | analysis    |      | review      |      | (1-10)   |      | verdict    |
   +---------+      +-------------+      +-------------+      +----------+      +------------+
```

### Stage 1 — INIT: Understand Everything First

Gang doesn't start with generic questions. It starts by **understanding your project deeply**:

1. **Deep codebase scan** — tech stack, features, architecture, domain model, auth, monetization signals, data sources
2. **Automated competitive research** — finds 5-8 competitors via web search, analyzes pricing models, table-stakes features, market gaps
3. **Presents findings for confirmation** — "Here's what I found about your project and market. Is this right?"
4. **Targeted questions only** — skips anything it already knows; questions reference YOUR project and YOUR competitors by name

```
Example prompt:

  /gang init

  I need to build a stock details page including prices, technical analysis,
  fundamental analysis, news, signals (intraday/swing), calendar, predictions,
  buy zones — and if I'm holding a position it should be marked.

  Design reference: web application/stitch/projects/6261359687710202709/screens/...
```

Gang will scan your codebase, find that it's a stock analysis app, research TradingView/TrendSpider/Trade Ideas as competitors, and then ask smart questions like *"Your codebase shows a SaaS subscription model — should the committee evaluate premium tier features for this page?"*

### Stage 2 — THINK: Six Experts, Zero Groupthink

Six domain experts analyze independently and in parallel (no agent sees another's work):

| Expert | Model | What They Produce |
|--------|-------|-------------------|
| **PM Lead** | Sonnet | Scope definition, RICE prioritization, MoSCoW requirements, MVP boundary, PRD |
| **Market Researcher** | Sonnet | TAM/SAM/SOM sizing, 12-dimension competitive scoring, Porter's Five Forces, SWOT, battle cards |
| **UX Researcher** | Sonnet | Personas, JTBD analysis, journey maps, wireframes, design tokens, interaction patterns, accessibility notes, **Google Stitch instructions** |
| **Finance/Risk Analyst** | Sonnet | DCF valuation, SaaS metrics (ARR/MRR/churn/CAC/LTV/NRR), risk matrix, scenario modeling (base/bull/bear/stress) |
| **Solutions Architect** | Sonnet | Feasibility scoring, architecture design, tech stack evaluation, build-vs-buy TCO, tech debt scoring, DORA metrics, ADRs |
| **Business Strategist** | Sonnet | Business Model Canvas, GTM strategy (3 phases), competitive moat assessment, pricing tiers, differentiation analysis |

### Stage 3 — DEBATE: Structured Adversarial Review

Two rounds of structured cross-review using the Board Meeting protocol:

- **Round 1 — Isolation Review:** Each expert critiques every other expert's position. The Executive Mentor adversarial pattern runs a pre-mortem on each position: *"Imagine this fails in 12 months — why?"*
- **Round 2 — Revision:** Each expert addresses critiques — accept with revision or reject with reasoning. Unresolved conflicts are logged for the CEO/CTO advisor.
- **Stress-test:** Downside scenarios modeled at -30%, -50%, -80% from base case.

### Stage 4 — SCORE: Quantified Decision Framework

1-2 competing plans scored on 5 dimensions (1-10 scale + confidence %):

| Dimension | What It Measures | Scored By |
|-----------|-----------------|-----------|
| Market Viability | Is there a real, reachable market? | Market Researcher + Business Strategist |
| User Desirability | Do users want this? Does it solve their pain? | UX Researcher + PM Lead |
| Technical Feasibility | Can we build it in the proposed timeline? | Solutions Architect |
| Financial Viability | Does the math work? Is ROI acceptable? | Finance/Risk Analyst |
| Strategic Alignment | Is it defensible? Does it fit our direction? | Business Strategist + PM Lead |

### Stage 5 — ADVISE: Executive Verdict (Opus)

The CEO/CTO Advisor (running on Opus for deepest reasoning) reads everything and produces an 11-section executive brief:

- **Go / No-Go / Conditional-Go** verdict
- Strategic options matrix with Tree of Thought analysis
- Capital allocation across 4 tiers
- Kill switches — decision checkpoints to exit early if assumptions break
- Downside scenarios with stress-test results
- 90-day implementation roadmap
- Quick wins to execute immediately

---

## Use Cases

### 1. "Should we build this?" — Full Product Evaluation

You have a product idea or an existing codebase. You want to know: Is this worth pursuing? What's the market? What should the MVP look like?

```
/gang run
```

Gang scans your project, researches the market, runs all 5 stages, and delivers a complete evaluation with a Go/No-Go verdict.

### 2. Feature-Level Evaluation

You're not evaluating the whole product — just a specific feature or page.

```
/gang init

I need to build a stock details page with prices, technical analysis,
fundamental analysis, news, signals, calendar, predictions, buy zones.
If I hold a position, it should be marked.
```

Gang focuses the entire committee on this specific feature — the Market Researcher analyzes what competitors' stock detail pages look like, the UX Researcher produces wireframes and Stitch instructions for this page, the Architect evaluates data source integration complexity.

### 3. Pivot or Stay — Strategic Decision

Your product is live but growth is stalling. Should you pivot, double down, or expand to an adjacent market?

```
/gang init

We have 2,000 MAU on our project management tool targeting freelancers.
Growth flatlined 3 months ago. Should we pivot to small teams,
add AI features, or find a different acquisition channel?
```

The committee evaluates each option independently, debates trade-offs, and the CEO/CTO advisor recommends the highest-EV path with clear kill switches.

### 4. Monetization Strategy

You have users but no revenue. How should you charge?

```
/gang init

We have a developer documentation tool with 15K weekly active users.
Currently free. Need to figure out pricing without killing growth.
```

The Finance Analyst benchmarks SaaS metrics, the Business Strategist models pricing tiers, the Market Researcher analyzes competitor pricing, and the PM Lead defines what goes in free vs. paid.

### 5. Pre-Fundraise Due Diligence

Simulate the tough questions investors will ask before you walk into the room.

```
/gang init

We're raising a seed round in Q3 for our AI-powered compliance
tool for fintech startups. Need to stress-test our pitch.
```

The committee acts like a skeptical investment committee — stress-testing market size, unit economics, technical moat, and competitive positioning. The executive brief becomes your prep document.

### 6. Competitive Repositioning

A new competitor just launched or an incumbent moved into your space.

```
/gang init

Stripe just launched a feature that overlaps with our core product.
How should we respond — differentiate, go upmarket, niche down, or pivot?
```

The Market Researcher does a deep competitive teardown, the Strategist evaluates positioning options, and the committee debates the best response.

---

## Installation

```bash
# Add the marketplace
claude plugin marketplace add https://github.com/ebnrdwan/GangPlugin

# Install the plugin
claude plugin install gang
```

Works in **Claude Code CLI**, **Claude Code Desktop** (Mac/Windows), and **IDE extensions** (VS Code, JetBrains).

## Usage

```bash
# Full 5-stage pipeline
/gang run

# Or run stages individually
/gang init       # Deep scan + competitive research + targeted questions
/gang think      # 6 experts analyze in parallel
/gang debate     # 2 rounds of structured cross-review
/gang score      # Synthesize and score competing plans
/gang advise     # CEO/CTO executive recommendation
/gang status     # Check progress and list artifacts
```

### Providing Context

Gang accepts any context in the init prompt — feature descriptions, design references, constraints, goals:

```
/gang init

Evaluate adding a social trading feature to our stock analysis app.
Users should be able to follow top traders, see their portfolios,
and copy trades. Budget is $50K. Need to ship in 3 months.
Stitch reference: web application/stitch/projects/.../screens/...
```

---

## Output Artifacts

All output is written to `.gang/` in your project directory:

```
.gang/
├── state.json                    # Session tracking
├── context-brief.md              # Project understanding + user context
├── competitive-scan.md           # Automated market research
├── position-papers/              # 6 independent expert analyses
│   ├── gang-pm-lead.md
│   ├── gang-market-researcher.md
│   ├── gang-ux-researcher.md
│   ├── gang-finance-risk-analyst.md
│   ├── gang-solutions-architect.md
│   └── gang-business-strategist.md
├── ux-deliverables/              # 9 UX output files
│   ├── personas.md
│   ├── jobs-to-be-done.md
│   ├── user-journeys.md
│   ├── information-architecture.md
│   ├── wireframes.md
│   ├── design-tokens.md
│   ├── interaction-patterns.md
│   ├── accessibility-notes.md
│   └── stitch-instructions.md    # Ready for Google Stitch
├── debate/
│   ├── round-1/                  # Cross-review critiques
│   └── round-2/                  # Revised positions
├── debate-log.md                 # Agreements, conflicts, kill switches
├── scored-plans.md               # Quantified plan comparison
└── executive-brief.md            # Go/No-Go + implementation roadmap
```

---

## Google Stitch Integration

The UX Researcher produces `stitch-instructions.md` — a structured prompt designed for [Google Stitch](https://stitch.withgoogle.com/). It includes:

- App overview and design direction
- Complete design system (OKLCH colors, typography, spacing, motion)
- Screen-by-screen component layouts with realistic content
- Global UI patterns (navigation, loading, empty states, errors)
- Anti-pattern rules to prevent generic AI-generated UI

Copy the contents directly into Google Stitch to generate production-quality UI screens.

---

## Design Quality

All UX output follows [Impeccable](https://github.com/pbakaus/impeccable) design rules:

- No default fonts (Inter, Poppins, Montserrat blocked)
- OKLCH color space with tinted neutrals (never pure gray)
- 4px/8px spacing grid strictly enforced
- WCAG AA contrast ratios on all text
- 44px minimum touch targets on mobile
- Mandatory focus states and reduced-motion support

---

## Why Multi-Agent Debate?

Single-agent AI gives you one perspective. That's a brainstorming partner, not a business committee.

Multi-agent debate is [proven to reduce hallucinations](https://link.springer.com/article/10.1007/s44443-025-00353-3), surface hidden assumptions, and produce more reliable analysis by forcing agents to critique each other's reasoning.

Gang takes this further with:

- **Role isolation** — experts analyze independently before seeing each other's work (prevents anchoring bias)
- **Structured adversarial review** — not just "what do you think?" but formal critique with pre-mortems and stress-tests
- **Quantified scoring** — every dimension gets a 1-10 score + confidence percentage, not just qualitative opinions
- **Kill switches** — explicit decision checkpoints where you should exit early if assumptions break
- **Confidence tagging** — claims are tagged as verified, medium-confidence, or assumed

---

## Expert Frameworks Reference

| Expert | Key Frameworks Used |
|--------|-------------------|
| PM Lead | RICE (Reach x Impact x Confidence / Effort), MoSCoW, PRD templates, MVP boundary setting |
| Market Researcher | 12-dimension competitive rubric, TAM/SAM/SOM, Porter's Five Forces, SWOT, positioning maps, battle cards |
| UX Researcher | Personas, JTBD, journey mapping, Impeccable design rules, OKLCH design tokens, Google Stitch DSL |
| Finance/Risk Analyst | DCF valuation, SaaS metrics benchmarking (HEALTHY/WATCH/CRITICAL), scenario modeling (base/bull/bear/stress), risk matrix (likelihood x impact) |
| Solutions Architect | Tech debt scoring (Severity x BlastRadius / Cost), DORA metrics, build-vs-buy TCO, Architecture Decision Records |
| Business Strategist | Business Model Canvas, GTM strategy (3 phases), competitive moat (Porter), pricing tier modeling, differentiation analysis |
| CEO/CTO Advisor | Strategic options matrix, Tree of Thought reasoning, 4-tier capital allocation, pre-mortem, stress-test, kill switches, 11-section executive brief |

---

## How It Compares

| Capability | Generic AI Chat | PM Tools (Linear, Notion AI) | Strategy Consultants | **Gang** |
|---|---|---|---|---|
| Understands your codebase | No | No | No | **Yes — deep scan** |
| Multi-perspective analysis | No | No | Yes ($$$$) | **Yes — 6 experts** |
| Adversarial debate | No | No | Sometimes | **Yes — 2 rounds + stress-test** |
| Quantified scoring | No | Partial | Yes | **Yes — 5 dimensions** |
| Competitive research | Manual | Manual | Manual | **Automated** |
| UX deliverables | No | No | Separate engagement | **Built-in + Stitch-ready** |
| Kill switches | No | No | Sometimes | **Yes — explicit checkpoints** |
| Lives in your IDE | No | No | No | **Yes — one command** |
| Cost | Free-$$$ | $8-20/seat/mo | $50K+ | **Your Claude API usage** |

---

## Requirements

- Claude Code (CLI, Desktop, or IDE extension)
- No additional dependencies — the plugin is self-contained
- WebSearch capability is used for competitive research in Stage 1

---

## License

MIT
