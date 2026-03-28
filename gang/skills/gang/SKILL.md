---
name: gang
description: "Multi-agent business committee that evaluates product ideas through structured expert debate. Use when: the user wants to evaluate a business idea, product concept, or strategic initiative; needs multi-perspective analysis (product, market, UX, finance, tech, strategy); wants scored strategic plans with Go/No-Go recommendation; needs Google Stitch-ready UI specifications; or asks to 'run a gang review', 'evaluate this idea', 'should we build this'. Subcommands: init, think, debate, score, advise, run, status."
version: 1.1.0
---

# Gang — Multi-Agent Business Committee

A 5-stage pipeline that orchestrates 6 domain experts + 1 CEO/CTO advisor through structured debate to produce scored strategic plans and executive-ready recommendations.

## Subcommand Router

Parse the user's command to determine which stage(s) to run:

| Command | Action |
|---------|--------|
| `/gang` or `/gang run` | Run ALL 5 stages end-to-end |
| `/gang init` | Stage 1 only — context onboarding |
| `/gang think` | Stage 2 only — parallel expert analysis |
| `/gang debate` | Stage 3 only — cross-review debate |
| `/gang score` | Stage 4 only — plan synthesis and scoring |
| `/gang advise` | Stage 5 only — CEO/CTO advisory |
| `/gang status` | Show current progress from `.gang/state.json` |

For stages 2-5, check that prerequisite stages are complete by reading `.gang/state.json`.
If prerequisites are missing, inform the user and suggest running the missing stage first.

---

## Stage 1 — INIT (Context Onboarding)

**Goal:** Deeply understand the project, research the competitive landscape, then ask smart targeted questions to produce a comprehensive context brief.

### Step 1: Initialize Workspace

Run the init script to create the `.gang/` directory structure:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-gang.sh
```

### Step 2: Deep Project Scan

This is NOT a quick check — it's a thorough understanding of the entire project.

**2a. Detect & classify the project:**
- Use Glob to find project files (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `build.gradle`, `*.xcodeproj`, `pubspec.yaml`, etc.)
- If no codebase found: skip to Step 3 in brief-only mode

**2b. Understand the product (use Explore agent for large codebases):**
- **Tech stack:** frameworks, languages, databases, APIs, third-party services
- **Product features:** scan routes, screens, pages, components, models, API endpoints
- **Domain model:** entities, relationships, key business objects
- **Architecture:** monolith vs microservices, frontend/backend split, mobile/web
- **Current state:** what's built vs stubbed, what's in progress, what's missing
- **User types:** roles, permissions, auth flows
- **Monetization signals:** pricing pages, subscription logic, payment integrations
- **Data sources:** external APIs, feeds, databases, scraping

**2c. Parse any user-provided context:**
- If the user included a specific feature request, page description, Stitch URL, Figma link, or screenshot — extract the requirements from it
- If a Stitch/Figma URL is provided, note it for the UX Researcher in Stage 2
- If the user described a specific page/feature, treat that as the primary evaluation subject (not the whole product)

**2d. Present understanding to the user:**
Show a concise summary of what you found:

```
📋 Project Understanding
━━━━━━━━━━━━━━━━━━━━━━━
Product: {name}
Type: {web app / mobile app / API / etc.}
Stack: {key technologies}
Domain: {what it does in 1-2 sentences}

Features Found:
  • {feature 1}
  • {feature 2}
  • ...

Evaluation Subject: {whole product / specific feature / specific page}
{If feature-specific: describe what the user wants to build/evaluate}
```

Ask: "Does this look right? Anything I'm missing?" — wait for confirmation before proceeding.

### Step 3: Competitive Research

**Before asking the user any questions**, research the market using WebSearch:

**3a. Identify competitors:**
- Search for products similar to what the project does
- Find 5-8 competitors (direct and indirect)
- For each, gather: name, URL, pricing model, key features, target audience, positioning

**3b. Analyze the competitive landscape:**
- What features are table-stakes in this market?
- What differentiators do top players use?
- What pricing models dominate?
- Where are the gaps/opportunities?
- If evaluating a specific feature/page: what do competitors' equivalent pages look like?

**3c. Write competitive scan:**
Write `.gang/competitive-scan.md`:

```markdown
# Competitive Scan

**Market:** {market category}
**Search Date:** {date}

## Competitors Found

| # | Name | URL | Model | Target | Key Differentiator |
|---|------|-----|-------|--------|-------------------|
| 1 | {name} | {url} | {pricing} | {audience} | {what makes them different} |
| ... | | | | | |

## Market Patterns
- **Table-stakes features:** {what every player has}
- **Common pricing:** {dominant pricing models}
- **Key differentiators:** {what separates winners from losers}
- **Underserved gaps:** {what nobody does well}

## Relevance to {project name}
- **Direct competitors:** {which compete head-to-head}
- **Indirect competitors:** {which solve adjacent problems}
- **Positioning opportunity:** {where this project can win}
```

**3d. Present findings to user:**
Show the key competitors found and ask the user to confirm, add, or correct. Use `AskUserQuestion`:

- Header: "I found these competitors — are they right?"
- Present the competitor list as context
- Options:
  - "Yes, that's the landscape" — "These are the right competitors to benchmark against"
  - "Add more" — "I know competitors you missed — let me add them"
  - "Remove some" — "Some of these aren't relevant to what we're building"
  - "Different market" — "We're actually competing in a different space"

### Step 4: Targeted Questions

NOW ask questions — but only what you couldn't determine from the codebase scan and competitive research. Use `AskUserQuestion` with 1-2 focused rounds.

**Rules:**
- SKIP any question whose answer is obvious from the scan (e.g., don't ask "what tech stack?" when you already scanned it)
- SKIP competitor questions — you already researched them
- Adapt options to be specific to THIS project and THIS market
- Reference what you found: "Based on the codebase, it looks like you're targeting retail traders — is that right?"

**Round 1 — Initiative & Strategy (3-4 questions max):**

Question 1 — "What should the committee focus on?"
- Header: "Evaluation Scope"
- Options (adapt based on what user already said + scan results):
  - "Full product strategy" — "Evaluate the entire vision, market fit, and growth path"
  - "This specific feature" — "Focus on {the feature/page they described}"
  - "Monetization model" — "Figure out the best way to monetize {product name}"
  - "Competitive positioning" — "How to differentiate against {top competitor names}"

Question 2 — "Who is your primary user?"
- Header: "Target User"
- Options (generated from scan — e.g., if it's a stock app):
  - "{Persona A from scan}" — "{description based on what you found}"
  - "{Persona B from scan}" — "{description}"
  - "{Persona C}" — "{description}"
  - "All of the above" — "Multiple user types with different needs"
- SKIP this question entirely if the answer is obvious from the codebase

Question 3 — "What's your business model?"
- Header: "Business Model"
- Options (informed by competitive scan):
  - "{Model competitors use most}" — "{description with market context}"
  - "{Alternative model}" — "{description}"
  - "{Differentiated model}" — "{description}"
  - "Let the committee recommend" — "Based on the competitive analysis"
- SKIP if pricing/subscription logic already exists in codebase

Question 4 — "What does 'winning' look like?"
- Header: "Success Criteria"
- Options:
  - "Best-in-class UX" — "Users switch from {competitor} because we're better"
  - "Revenue milestone" — "Hit a specific MRR/ARR target"
  - "User growth" — "Reach a critical mass of active users"
  - "Feature parity + differentiation" — "Match {competitor} then surpass on {area}"

**Round 2 — Constraints (2-3 questions, skip what's obvious):**

Question 5 — "Team & timeline?"
- Header: "Execution Capacity"
- Options:
  - "Solo / small team, ship fast" — "1-3 people, want results in <3 months"
  - "Growing team, medium horizon" — "5-10 people, 6-month roadmap"
  - "Full team, building deliberately" — "10+ people, long-term play"
  - "Already live, iterating" — "Product is in market, optimizing"

Question 6 — "Any hard constraints the committee should know about?"
- Header: "Constraints"
- multiSelect: true
- Options (adapt to domain — e.g., for fintech):
  - "{Domain-specific regulation}" — "{e.g., SEC/FINRA compliance for stock apps}"
  - "Limited budget" — "Bootstrapped or tight funding"
  - "Technical migration needed" — "Significant refactoring or platform change"
  - "No major constraints" — "Flexible on approach"

### Step 5: Produce Context Brief

Write `.gang/context-brief.md` incorporating EVERYTHING: scan results, competitive research, user answers, and any feature-specific context.

```markdown
# Gang Context Brief

**Date:** {date}
**Session:** {session_id from state.json}
**Subject:** {product/initiative name}
**Scope:** {whole product / specific feature / specific page}

## Product Overview
{What this product is and does — from codebase scan, not guesswork}
{Tech stack, architecture, current state of development}

## Evaluation Subject
{What specifically the committee should evaluate}
{If feature-specific: full description of the feature/page, including any Stitch URLs, screenshots, or design references the user provided}

## Problem Statement
{The problem this product/feature solves, who has it, how painful it is}

## Target Users
{Primary and secondary user descriptions — from scan + user input}

## Competitive Landscape
{Summary from competitive-scan.md — top competitors, market patterns, gaps}
{Reference: see .gang/competitive-scan.md for full analysis}

## Business Model
{Current or proposed monetization approach}

## Current State
{What exists today — features built, features missing, technical debt}
{Architecture and tech decisions already made}

## Constraints
{Budget, timeline, team, regulatory, technical}

## Success Criteria
{What "good" looks like — specific and measurable}

## Design References
{Any Stitch URLs, Figma links, screenshots, or wireframes the user provided}
{Note: UX Researcher should use these as primary input in Stage 2}

## Open Questions
{Anything the user was uncertain about — experts should address these}
{Questions that emerged from competitive research}
```

### Step 6: Update State

Update `.gang/state.json`: add "init" to `stages_completed`, set `current_stage` to "think".

---

## Stage 2 — THINK (Parallel Expert Analysis)

**Goal:** 6 experts independently analyze the context brief and produce position papers.

### Dispatch All 6 Experts in Parallel

Use the Agent tool to dispatch ALL 6 agents in a SINGLE message (parallel execution):

For each agent, provide this prompt template (customize the agent name):

> Read the context brief at `.gang/context-brief.md`. You are participating in a Gang business committee evaluation.
>
> Produce your position paper following your agent instructions exactly. Write your output to `.gang/position-papers/{agent-name}.md`.
>
> Also read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md` — you will need it in the next stage.
>
> {For gang-ux-researcher only: Also produce all 9 UX deliverable files in `.gang/ux-deliverables/`. Read the Impeccable design rules at `{plugin_root}/skills/gang/references/impeccable-design-rules.md` and the Stitch template at `{plugin_root}/skills/gang/references/stitch-prompt-template.md`.}

**Agents to dispatch:**
1. `gang-pm-lead` — scope, RICE, requirements, MVP
2. `gang-market-researcher` — TAM/SAM/SOM, competitive, trends, SWOT
3. `gang-ux-researcher` — personas, JTBD, journeys, design tokens, Stitch instructions
4. `gang-finance-risk-analyst` — costs, ROI, SaaS metrics, risk matrix, scenarios
5. `gang-solutions-architect` — feasibility, architecture, tech stack, build-vs-buy
6. `gang-business-strategist` — positioning, GTM, business model, moat, pricing

### After Dispatch

Once all 6 agents complete:
1. Verify all 6 position papers exist in `.gang/position-papers/`
2. Verify UX deliverables exist in `.gang/ux-deliverables/` (9 files)
3. Present a summary to the user: which experts completed, key headline from each position paper
4. Update `.gang/state.json`: add "think" to `stages_completed`, set `current_stage` to "debate"

---

## Stage 3 — DEBATE (Cross-Review, 2 Rounds)

**Goal:** Experts challenge each other's positions, revise based on feedback, surface conflicts.

The debate follows the Board Meeting 3-phase protocol (Framing → Isolation → Debate) combined with Executive Mentor adversarial patterns. See `${CLAUDE_PLUGIN_ROOT}/skills/gang/references/debate-protocol.md` for full rules.

### Round 1: Isolation Review

Dispatch all 6 agents in parallel. Each agent's prompt:

> You are in Stage 3 Round 1 of the Gang debate. Read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md`.
>
> Read ALL position papers in `.gang/position-papers/`. For each OTHER expert's position, write a critique following the Round 1 format in the debate protocol.
>
> Apply the Executive Mentor pre-mortem pattern: For each position, ask "Imagine this fails in 12 months — why?" Extract assumptions, rate confidence × impact, find vulnerabilities.
>
> Identify the top 3 cross-cutting assumptions that need stress-testing.
>
> Write your complete review to `.gang/debate/round-1/{agent-name}-review.md`.

### Round 2: Debate & Revision

After Round 1 completes, dispatch all 6 agents in parallel. Each agent's prompt:

> You are in Stage 3 Round 2 of the Gang debate. Read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md`.
>
> Read your original position paper at `.gang/position-papers/{agent-name}.md`.
> Read ALL Round 1 reviews in `.gang/debate/round-1/`.
>
> Produce a revised position following the Round 2 format in the debate protocol. You MUST address every critique directed at your position — either accept it (show the revision) or reject it (explain why).
>
> Log any unresolved conflicts in the "Unresolved Conflicts" section.
>
> Write to `.gang/debate/round-2/{agent-name}-revised.md`.

### Compile Debate Log

After Round 2 completes, compile `.gang/debate-log.md`:
- Read all Round 2 revised positions
- Extract: resolved agreements, resolved-through-debate items, unresolved conflicts
- Extract: stress-test results from Round 1 reviews
- Extract: kill switches proposed by any expert
- Follow the debate log format in the debate protocol reference file

Present debate highlights to the user: key agreements, key conflicts, what changed.

Update `.gang/state.json`: add "debate" to `stages_completed`, set `current_stage` to "score".

---

## Stage 4 — SCORE (Plan Synthesis)

**Goal:** Synthesize 1-2 competing plans from the converged debate and score them.

### Synthesize Plans

Read all Round 2 revised positions and the debate log. Identify:
- What the committee AGREES on (these form the core of every plan)
- Where the committee DIVERGES (these create the differences between plans)

Produce 1-2 competing plans. If the committee largely agreed, produce 1 plan with variants.
If there were significant unresolved conflicts, produce 2 distinct plans representing each camp.

### Score Each Plan

Score on 5 dimensions (1-10 scale + confidence percentage):

| Dimension | Description | Score Sources |
|-----------|-------------|--------------|
| Market Viability | Is there a real market? Can we reach it? | Market Researcher + Business Strategist |
| User Desirability | Do users want this? Does it solve their problem? | UX Researcher + PM Lead |
| Technical Feasibility | Can we build it? In the proposed timeline? | Solutions Architect |
| Financial Viability | Does the math work? Is ROI acceptable? | Finance/Risk Analyst |
| Strategic Alignment | Does this fit our strategy? Is it defensible? | Business Strategist + PM Lead |

### Output

Write `.gang/scored-plans.md`:

```markdown
# Gang Scored Plans

## Plan A: {name}
{Brief description of the plan — what's included, what's cut, key approach}

| Dimension | Score | Confidence | Key Evidence |
|-----------|-------|------------|-------------|
| Market Viability | {1-10} | {%} | {1-sentence reason} |
| User Desirability | {1-10} | {%} | {reason} |
| Technical Feasibility | {1-10} | {%} | {reason} |
| Financial Viability | {1-10} | {%} | {reason} |
| Strategic Alignment | {1-10} | {%} | {reason} |
| **Weighted Average** | **{score}** | **{avg confidence}** | |

### Strengths
- {key strength}

### Weaknesses
- {key weakness}

### Best For
{When/why you'd choose this plan}

---

## Plan B: {name} (if applicable)
{Same structure}

---

## Recommendation
{Which plan scores higher and why. Note any dimension where Plan B beats Plan A.}
```

Present the scored plans to the user with a visual summary.

Update `.gang/state.json`: add "score" to `stages_completed`, set `current_stage` to "advise".

---

## Stage 5 — ADVISE (CEO/CTO Advisory)

**Goal:** Final executive synthesis with Go/No-Go recommendation.

### Dispatch CEO/CTO Advisor

Use the Agent tool to dispatch `gang-ceo-cto-advisor` (runs on Opus for deepest reasoning):

> You are the CEO/CTO Advisor for the Gang business committee. This is Stage 5 — the final advisory.
>
> Read ALL of these files:
> - `.gang/context-brief.md`
> - All files in `.gang/position-papers/`
> - All files in `.gang/debate/round-2/`
> - `.gang/debate-log.md`
> - `.gang/scored-plans.md`
>
> Produce your executive brief following your agent instructions exactly.
> Write to `.gang/executive-brief.md`.

### Present Results

After the advisor completes:
1. Read `.gang/executive-brief.md`
2. Present the key findings to the user:
   - **Verdict:** Go / No-Go / Conditional-Go
   - **Top 3 risks**
   - **Kill switches** (the decision checkpoints)
   - **Quick wins** (what to do first)
3. Remind the user about the UX deliverables: "Google Stitch instructions are at `.gang/ux-deliverables/stitch-instructions.md`"
4. Enter interactive mode: "Ask me anything about the committee's findings."

Update `.gang/state.json`: add "advise" to `stages_completed`, set `current_stage` to "complete".

---

## Status Command

When the user runs `/gang status`:

1. Read `.gang/state.json`
2. Check which files exist in `.gang/`
3. Present a progress report:

```
Gang Committee Status
━━━━━━━━━━━━━━━━━━━━
Session: {session_id}
Started: {started_at}

[✓] Stage 1: INIT — Context brief ready
[✓] Stage 2: THINK — 6/6 position papers complete
[→] Stage 3: DEBATE — Round 1 complete, Round 2 in progress
[ ] Stage 4: SCORE — Not started
[ ] Stage 5: ADVISE — Not started

Artifacts:
  .gang/context-brief.md .............. ✓
  .gang/position-papers/ .............. 6 files
  .gang/ux-deliverables/ .............. 9 files
  .gang/debate/round-1/ ............... 6 files
  .gang/debate/round-2/ ............... 0 files
  .gang/debate-log.md ................. pending
  .gang/scored-plans.md ............... pending
  .gang/executive-brief.md ............ pending

Next: Run /gang debate to continue
```

---

## Error Handling

- If an agent fails to produce output, report which agent failed and offer to retry just that agent
- If `.gang/state.json` doesn't exist, suggest running `/gang init` first
- If a stage is run out of order, show which prerequisites are missing
- If the user wants to restart a stage, warn that it will overwrite existing output for that stage

## Token Budget Awareness

This workflow is token-intensive. Mitigations:
- Position papers are capped at 1500 words each (tables excluded)
- The CEO/CTO Advisor gets a SUMMARY of debate, not raw Round 1 reviews
- UX deliverables are written to separate files, not inlined in the position paper
- Each agent reads only what it needs for its current stage
