---
name: gang
description: "Multi-agent business committee that evaluates product ideas through structured expert debate. Use when: the user wants to evaluate a business idea, product concept, or strategic initiative; needs multi-perspective analysis (product, market, UX, finance, tech, strategy); wants scored strategic plans with Go/No-Go recommendation; needs Google Stitch-ready UI specifications; or asks to 'run a gang review', 'evaluate this idea', 'should we build this'. Subcommands: init, think, debate, score, advise, deliver, reinit, run, status, config, evaluations, validate."
version: 1.3.1
---

# Gang — Multi-Agent Business Committee v1.3.1

A 6-stage pipeline that orchestrates configurable domain experts through structured debate to produce evidence-backed, rubric-anchored scored strategic plans and executive-ready recommendations. Every aspect is configurable: roles, debate mode, cost budget, model routing, evidence linking, scoring rubrics, validation, and failure handling.

## Conventions

Throughout this document:
- **`{output_root}`** — resolved from `state.json.output_root` (e.g., `.gang/`, `.gang/features/stock-details/`, `.gang/projects/mobile-app/`)
- **`{plugin_root}`** — resolved from `${CLAUDE_PLUGIN_ROOT}`
- **`config`** — loaded from `.gang/config.yaml`

---

## Subcommand Router

Parse the user's command to determine which stage(s) to run:

| Command | Action |
|---------|--------|
| `/gang` or `/gang run` | Run ALL 6 stages end-to-end |
| `/gang init` | Stage 1 only — context onboarding, evidence population |
| `/gang think` | Stage 2 only — committee setup + parallel expert analysis |
| `/gang debate` | Stage 3 only — cross-review debate |
| `/gang score` | Stage 4 only — rubric-anchored plan synthesis and scoring |
| `/gang advise` | Stage 5 only — CEO/CTO advisory with guardrails |
| `/gang deliver` | Stage 6 — generate GO Package (requires GO/CONDITIONAL-GO) |
| `/gang reinit` | Re-run INIT on existing session — refreshes context, resets downstream |
| `/gang status` | Show current progress, committee roster, cost, validation |
| `/gang config` | Show or edit `.gang/config.yaml` |
| `/gang evaluations` | List all evaluations (features + projects) |
| `/gang validate` | Run validation checks on current session |

For stages 2-6, check that prerequisite stages are complete by reading `{output_root}/state.json`.
If prerequisites are missing, inform the user and suggest running the missing stage first.

---

## Config Loading

**Every stage** begins by loading configuration:

1. Read `.gang/config.yaml` — if missing, use defaults from `{plugin_root}/skills/gang/references/default-config.yaml`
2. Resolve `{output_root}` from `{output_root}/state.json` (or `.gang/` for flat)
3. Read `{output_root}/state.json` for session state
4. Check cost budget before dispatching any agents (see Cost Management)

---

## Cost Management

### When `config.cost.enabled` is true:

**Before each stage:**
1. Read `{output_root}/state.json` cost totals
2. If `budget_limit > 0`:
   - At `warn_at`% → show warning: "Budget at {X}% — consider switching to light mode or fewer agents"
   - At `block_at`% → block and ask: "Budget reached {X}%. Continue anyway? [yes/no]"

**Estimation method:**
- For each agent dispatch: estimate tokens = (sum of input file sizes in bytes / 4) + 500 (system prompt overhead)
- Output estimate: input tokens * 0.5 (typical generation ratio)
- Cost = (input_tokens / 1M * input_rate) + (output_tokens / 1M * output_rate)
- Use rates from `config.cost.model_rates` for the agent's resolved model

**After each agent completes:**
- Update `state.json.cost.stages.{stage}.tokens_in`, `tokens_out`, `estimated_usd`
- Update `state.json.cost.stages.{stage}.by_agent.{agent_name}` with per-agent breakdown
- Update `state.json.cost.total_estimated_usd`

### Budget-Adaptive Routing (when `config.routing.mode` is `budget-adaptive`):

When approaching budget limits, auto-downgrade models using `config.routing.downgrade_priority` (last entry downgrades first):
- At 60% budget: opus → sonnet for agents not in top-3 priority
- At 80% budget: sonnet → haiku for agents not in top-2 priority
- CEO/CTO Advisor (first in priority list) is ALWAYS last to downgrade

Show the user when a downgrade occurs: "Budget at {X}% — downgrading {agent} from {old_model} to {new_model}"

---

## Model Routing

### Resolving which model an agent uses:

1. **Manual mode** (`config.routing.mode: manual`): Use `config.roles.{agent}.model` exactly
2. **Budget-adaptive** (`config.routing.mode: budget-adaptive`): Start with configured model, downgrade based on budget (see above)
3. **Multi-provider** (`config.routing.mode: multi-provider`): Check if agent is in any provider's `best_for` list:
   - If yes AND that provider is enabled AND the API key env var is set → route to external provider via `{plugin_root}/scripts/external-dispatch.sh`
   - If external dispatch fails → fallback to the provider's configured `fallback` Claude model
   - If no external match → use Claude model from `config.roles.{agent}.model`

### External Provider Dispatch

When routing to an external provider:

1. Gather all input files the agent needs (context brief, evidence, etc.)
2. Construct the agent's prompt (same as the Claude dispatch prompt)
3. Call: `bash {plugin_root}/scripts/external-dispatch.sh --provider {name} --model {model} --input {prompt_file} --output {output_file}`
4. Check exit code:
   - `0`: Success — read output file and continue
   - `10`: Provider unavailable → try fallback
   - `11`: Malformed response → try fallback
   - `12`: Timeout → try fallback
   - `13`: Rate limited → try fallback
5. Log result in `state.json.agent_results.{agent}`

---

## Failure Handling

### When `config.failure_handling.enabled` is true:

For each agent dispatch (Claude or external):

1. **Primary attempt** — dispatch with resolved model/provider
2. **On failure:**
   - If `retry_on_failure` and retries < `max_retries`: retry once
   - If budget > 80% and `skip_expensive_retry_over_budget`: skip retry with expensive model
   - If still fails and `fallback_on_failure`: try the fallback Claude model (haiku)
   - If all fails: mark agent as `status: failed` in `state.json.agent_results`
3. **Record in state.json:**
   ```json
   "agent_results": {
     "{agent-name}": {
       "status": "success|failed|incomplete|skipped",
       "model_used": "{model}",
       "provider": "{claude|perplexity|gemini|copilot}",
       "error_code": null,
       "fallback_attempted": false
     }
   }
   ```

### Partial Failure Impact

If any **core agent** (PM Lead, Finance Analyst, Solutions Architect) fails:
- ADVISE stage MUST state: "Analysis incomplete: missing {agent} perspective due to provider failure."
- CEO/CTO Advisor degrades overall confidence
- Cannot issue unconditional GO with missing core agent

---

## Validation

### When `config.validation.enabled` is true:

**Between stages** (when `validate_between_stages` is true):
Run validation checks before proceeding to next stage:

1. **File presence** (`validate_file_presence`): verify expected files exist for completed stages
2. **Evidence refs** (`validate_evidence_refs`): check `evidence_ids` in position papers reference entries in `{output_root}/evidence.json`
3. **Assumption refs** (`validate_assumption_refs`): check `assumption_ids` reference entries in `{output_root}/assumptions.json`
4. **Required sections** (`validate_required_sections`): check position papers have required headings (`## Bottom Line`, etc.)

**On validation failure:**
- If `strict: true` → STOP, show detailed errors, ask user to fix before continuing
- If `strict: false` → WARN, show errors, continue anyway

**Manual validation:** `/gang validate` runs all checks and prints a report.

---

## Stage 1 — INIT (Context Onboarding + Evidence Population)

**Goal:** Deeply understand the project, research the competitive landscape, populate the evidence ledger, ask smart targeted questions, and produce a comprehensive context brief.

### Step 0: Quality Mode Selection

Before anything else, ask the user which quality mode to use. Use `AskUserQuestion`:

- Header: "Which evaluation mode?"
- Context: "This controls committee depth, debate style, budget, and validation rigor."
- Options:
  - "Quick Scout ($~1)" — "Fast directional read. 3 agents, light mode, 1 debate round. Good for early-stage filtering."
  - "Product Review ($~5)" — "Balanced analysis. 5 agents, deep mode, selective debate. Default for features."
  - "Investment Grade ($~20)" — "Full committee. All agents deep, rubric-anchored scoring, external providers, strict validation."
  - "Custom" — "I'll configure everything myself in config.yaml"

Based on selection:
1. Load the preset from `config.modes.{selected_mode}` in default-config.yaml
2. Apply preset values to `.gang/config.yaml` (enable/disable roles, set weights, debate mode, budget, etc.)
3. If "Custom" → tell user to edit `.gang/config.yaml` and run `/gang init` again when ready

### Step 1: Initialize Workspace

Ask the user what they're evaluating. Use `AskUserQuestion`:

- Header: "What are we evaluating?"
- Options:
  - "A specific feature" — "Evaluate a single feature (saved in .gang/features/{name}/)"
  - "The whole project" — "Evaluate the entire product/project (saved in .gang/projects/{name}/)"
  - "Quick flat evaluation" — "Simple evaluation, files in .gang/ directly"

Based on selection:
- **Feature:** Ask for a slug name → run `bash {plugin_root}/scripts/init-gang.sh --type feature --name {slug}`
- **Project:** Ask for a slug name → run `bash {plugin_root}/scripts/init-gang.sh --type project --name {slug}`
- **Flat:** Run `bash {plugin_root}/scripts/init-gang.sh --type flat`

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

**2c. Populate Evidence Ledger (codebase scan):**

When `config.evidence.enabled` and `config.evidence.auto_populate_from_init` are true:

For each significant finding from the project scan, add an entry to `{output_root}/evidence.json`:
```json
{
  "id": "ev-001",
  "source": "codebase-scan",
  "file": "{relative path}",
  "date": "{YYYY-MM-DD}",
  "type": "{tech-stack|feature-inventory|architecture|domain-model|monetization|auth-flow|data-source|dependency}",
  "text": "{factual statement about what was found}",
  "confidence": 0.95
}
```

Codebase evidence gets high confidence (0.85-0.99) since it's directly observed.

**2d. Parse any user-provided context:**
- If the user included a specific feature request, page description, Stitch URL, Figma link, or screenshot — extract the requirements from it
- If a Stitch/Figma URL is provided, note it for the UX Researcher in Stage 2
- If the user described a specific page/feature, treat that as the primary evaluation subject

**2e. Present understanding to the user:**
Show a concise summary of what you found:

```
Project Understanding
━━━━━━━━━━━━━━━━━━━━━━━
Product: {name}
Type: {web app / mobile app / API / etc.}
Stack: {key technologies}
Domain: {what it does in 1-2 sentences}

Features Found:
  - {feature 1}
  - {feature 2}
  - ...

Evidence Collected: {N} entries from codebase scan

Evaluation Subject: {whole product / specific feature / specific page}
{If feature-specific: describe what the user wants to build/evaluate}
```

Ask: "Does this look right? Anything I'm missing?" — wait for confirmation before proceeding.

### Step 3: Competitive Research + Web Evidence

**Before asking the user any questions**, research the market.

**3a. Web Research (when `config.evidence.web_research.enabled` is true):**

Determine the research provider based on `config.evidence.web_research.preferred_provider`:
- **`auto`**: try providers in `fallback_chain` order (first available)
- **`perplexity`/`gemini`/`claude`**: use that provider directly, fall back through chain on failure

For **Claude** web research: use WebSearch tool with the configured model.
For **Perplexity/Gemini**: use `{plugin_root}/scripts/external-dispatch.sh` with a research prompt.

If `web_research.enabled: false` → skip web research entirely. Evidence only has codebase facts.

**3b. Identify competitors:**
- Search for products similar to what the project does
- Find 5-8 competitors (direct and indirect)
- For each, gather: name, URL, pricing model, key features, target audience, positioning

**3c. Populate Evidence Ledger (web research):**

For each market/competitive finding, add to `{output_root}/evidence.json`:
```json
{
  "id": "ev-{next_id}",
  "source": "{perplexity-sonar-pro|gemini-2.5-pro|claude-websearch}",
  "url": "{source URL}",
  "date": "{YYYY-MM-DD}",
  "type": "{competitor-pricing|competitor-feature|market-size|market-trend|user-behavior|regulatory|benchmark|financial-data|industry-report}",
  "text": "{factual statement}",
  "confidence": {0.5-0.9 depending on source quality}
}
```

**3d. Write competitive scan:**
Write `{output_root}/competitive-scan.md` with the same format as v1.2.0.

**3e. Present findings to user:**
Show the key competitors found and ask the user to confirm, add, or correct. Use `AskUserQuestion`.

### Step 4: Targeted Questions

Same as v1.2.0 — SKIP questions whose answers are obvious from scan. Adapt options to this specific project/market.

**Round 0 — Domain Expert (always ask):**

Question 0 — "Include a Domain Expert?"
If yes: run the **Domain Expert Profiling Interview** below, then generate `{output_root}/domain-expert-profile.md` using the template at `{plugin_root}/skills/gang/references/domain-expert-template.md`. Update `state.json.domain_expert_enabled: true`.

#### Domain Expert Profiling Interview

When the user opts in, ask 3 rounds of questions using `AskUserQuestion`. The goal is to build an expert profile that **challenges assumptions and surfaces real constraints** — NOT one that confirms existing plans. All questions adapt to the domain detected from the project scan.

**Profiling Round 1 — Domain & Perspective (2 questions, single AskUserQuestion call):**

Question P1a — "Which domain lens should the expert use?"
- Auto-detect the primary domain from the project scan (e.g., fintech, healthtech, e-commerce, edtech, logistics, social, SaaS).
- Present 3-4 options: the detected domain + 2-3 adjacent domains that offer a different but relevant angle.
- Example for a stock app: "Retail Brokerage Technology", "Financial Data & Analytics", "Consumer Fintech", "Regulatory Compliance (SEC/FINRA)"
- The user may pick one OR specify a custom domain.

Question P1b — Sub-Specialization (conditional — only ask when the domain has meaningful sub-categories)

Many domains have internal specializations where the expert's advice changes dramatically depending on the niche. After P1a is answered, check if the chosen domain has sub-categories that would materially change the expert's perspective. If yes, ask this question in the SAME AskUserQuestion call as P2. If the domain is narrow enough already, skip P1b.

**When to ask P1b:** The domain has sub-categories where regulations, user behavior, unit economics, or technical requirements differ significantly between niches.

**When to skip P1b:** The domain is already specific enough (e.g., user picked "Regulatory Compliance (SEC/FINRA)" — that's already a niche).

Generate options dynamically based on the P1a answer. Examples by domain:

- **Finance / Trading / Signals:**
  - Trading style: "Intraday / Scalping" — "Sub-minute to same-day holds. Real-time data, low latency, pattern recognition, PDT rules." | "Swing Trading" — "Multi-day to multi-week holds. Technical analysis, momentum, risk/reward setups." | "Long-term Investing" — "Months to years. Fundamentals, portfolio construction, suitability, fiduciary." | "Algorithmic / Quantitative" — "Automated strategies, backtesting, execution algorithms, market microstructure."
  - Asset class: "Equities (US stocks)" — "SEC/FINRA regulated, exchange data licensing, market hours." | "Commodities / Metals" — "CFTC regulated, futures contracts, margin requirements, geopolitical factors." | "Forex" — "Decentralized, 24/5, high leverage, NFA regulated, different broker models." | "Crypto" — "24/7, exchange-specific, evolving regulation, custody concerns."
  - If both sub-categories are relevant (e.g., a signals app covers trading style AND asset class), ask both as multiSelect or two separate options within P1b.

- **Healthcare / Healthtech:**
  - Specialty: "Primary Care" | "Specialty / Surgery" | "Mental Health / Behavioral" | "Chronic Disease Management"
  - Care model: "Fee-for-Service" | "Value-Based Care" | "Direct-to-Consumer (DTC)" | "B2B (Health Systems / Payers)"

- **E-commerce / Marketplace:**
  - Product type: "Physical Goods" | "Digital Products / SaaS" | "Services Marketplace" | "Subscription Commerce"
  - Market segment: "B2C Consumer" | "B2B / Wholesale" | "D2C (Direct to Consumer)" | "Cross-border / International"

- **Education / Edtech:**
  - Audience: "K-12 Students" | "Higher Education" | "Professional / Corporate Training" | "Self-directed Learners"
  - Model: "Live / Synchronous" | "Self-paced / Async" | "Cohort-based" | "Tutoring / 1-on-1"

- **Logistics / Supply Chain:**
  - Segment: "Last-mile Delivery" | "Freight / LTL" | "Warehousing / Fulfillment" | "Fleet Management"
  - Scope: "Domestic" | "Cross-border / International" | "Cold Chain / Specialized" | "Returns / Reverse Logistics"

For domains not listed above, dynamically generate 3-4 sub-specialization options based on the project scan findings. If the project scan reveals enough specifics to determine the sub-category (e.g., code clearly shows intraday candle data + real-time WebSocket feeds), pre-select the detected niche as the first option and mark it "(Detected from codebase)".

**Impact of P1b on the profile:** Sub-specialization answers directly shape:
- `## Your Persona` — the expert's specific experience (e.g., "10 years building swing trading signal platforms" vs "former commodity futures desk analyst")
- `## Key Expertise Areas` — niche-specific knowledge (e.g., PDT rules for intraday vs suitability rules for long-term)
- `## Industry Benchmarks` — metrics vary dramatically by niche (e.g., signal accuracy expectations: 55% for intraday scalping is good, 55% for long-term value picks is terrible)
- `## Common Pitfalls` — niche-specific traps (e.g., "calling intraday signals 'predictions' without disclaimers" vs "recommending individual stocks without suitability assessment")

Question P2 — "What perspective should the expert bring?"
- Options should represent different vantage points, NOT different levels of optimism:
  - "Industry Practitioner" — "Built products in this space. Knows what actually works vs what sounds good in a pitch deck."
  - "Regulatory / Compliance" — "Focuses on what's legally required, what creates liability, and what gets companies fined."
  - "End-User / Domain Customer" — "Thinks like the actual user. Knows their real workflows, frustrations, and alternatives."
  - "Market Analyst / Economist" — "Tracks industry trends, unit economics, and market structure. Knows who survives downturns."

**Profiling Round 2 — Risk Focus & Blind Spots (2 questions, single AskUserQuestion call):**

Question P3 — "What should the expert be most skeptical about?"
- This question surfaces the user's own uncertainty — where they WANT pushback. Frame it neutrally:
  - "Market demand assumptions" — "Is there real demand, or are we projecting our own needs?"
  - "Technical feasibility claims" — "Can we actually build this at the proposed scale/cost/timeline?"
  - "Regulatory & legal exposure" — "Are there compliance, licensing, or liability risks we're underestimating?"
  - "Competitive defensibility" — "Can incumbents copy this trivially? Is the moat real?"

Question P4 — "What do teams in this domain typically get wrong?"
- This primes the expert to catch common domain-specific mistakes. Options adapt to the detected domain AND sub-specialization from P1b:
  - For fintech (general): "Underestimating data licensing costs", "Ignoring compliance until launch", "Assuming users want more features vs simplicity", "Building for traders instead of investors"
  - For fintech + intraday signals: "Calling signals 'predictions' without risk disclaimers", "Underestimating real-time data costs (exchange licensing)", "Ignoring PDT rule implications for users with <$25K", "Assuming backtested accuracy translates to live performance"
  - For fintech + swing trading: "Overpromising signal accuracy without track record", "Not differentiating from free TradingView strategies", "Ignoring the 'signal fatigue' problem (too many alerts)", "Assuming technical analysis has predictive power without evidence"
  - For fintech + long-term investing: "Giving stock recommendations without RIA registration", "Ignoring suitability requirements", "Competing with free robo-advisors on features", "Assuming retail investors stick with paid tools in bear markets"
  - For fintech + commodities/metals: "Not accounting for CFTC (not SEC) regulatory framework", "Underestimating margin requirement complexity", "Ignoring geopolitical risk modeling", "Assuming equity-market user behavior applies to commodities"
  - For healthtech: "Underestimating HIPAA scope", "Assuming doctors will change workflows", "Ignoring reimbursement models", "Building for patients when payers decide"
  - For e-commerce: "Ignoring unit economics at scale", "Underestimating logistics complexity", "Assuming marketplace network effects are automatic", "Over-investing in acquisition vs retention"
  - For SaaS: "Underestimating enterprise sales cycles", "Assuming self-serve scales forever", "Ignoring churn compounding", "Building features before validating willingness-to-pay"
  - Generate domain+niche-appropriate options dynamically based on project scan and P1b answer.

**Profiling Round 3 — Benchmarks & Success Criteria (1 question):**

Question P5 — "What should the expert benchmark success against?"
- This defines what "good" looks like in the domain — the expert uses these to evaluate proposals:
  - "Industry unit economics" — "CAC, LTV, payback period, margins for this vertical"
  - "Competitor feature parity" — "What do top 3 competitors offer as table stakes?"
  - "Regulatory compliance bar" — "What's the minimum to operate legally in target markets?"
  - "User adoption benchmarks" — "Typical activation rates, retention curves, NPS for this category"

#### Building the Profile

After all profiling questions are answered, generate `{output_root}/domain-expert-profile.md` using the template:

1. Map P1a answer → `## Domain` (broad domain)
2. Map P1b answer (if asked) → refine `## Domain` with sub-specialization, shape `## Key Expertise Areas` to the specific niche, calibrate `## Industry Benchmarks` to niche-appropriate metrics
3. Map P2 answer → `## Your Persona` (craft the persona to match the chosen perspective AND sub-specialization)
4. Map P3 answer → `## Common Pitfalls in This Domain` (prioritize the skepticism area)
5. Map P4 answer → add to `## Common Pitfalls` + `## Industry Frameworks & Standards` (these are now niche-specific thanks to P1b)
6. Map P5 answer → `## Industry Benchmarks` and `## Competitive Dynamics`
7. Enrich all sections with findings from the project scan and web research (evidence.json)

**Critical rule:** The generated profile must NOT contain any positive assumptions about the project. The domain expert's job is to stress-test, not validate. The persona should be someone who has "seen projects like this fail" and knows exactly why.

**Round 1 — Initiative & Strategy (3-4 questions max)**
**Round 2 — Constraints (2-3 questions)**

(Same question structure as v1.2.0 — see questions 1-6)

### Step 5: Produce Context Brief

Write `{output_root}/context-brief.md` incorporating EVERYTHING: scan results, competitive research, evidence ledger summary, user answers, and any feature-specific context.

Use the same format as v1.2.0 but add:

```markdown
## Evidence Base
{N} evidence entries collected ({M} from codebase scan, {K} from web research).
Full evidence ledger: `{output_root}/evidence.json`
Full assumptions ledger: `{output_root}/assumptions.json`

Agents MUST follow the Evidence & Assumptions Protocol (see dispatch prompts).
```

### Step 6: Update State

Update `{output_root}/state.json`:
- Add "init" to `stages_completed`
- Set `current_stage` to "think"
- Update cost estimates for INIT stage
- Update `active_agents` based on config roles

### Step 7: Validate (if enabled)

If `config.validation.validate_between_stages` is true:
- Verify `evidence.json` is valid (non-empty array, IDs sequential)
- Verify `context-brief.md` exists
- Verify `state.json` is valid
- Report results; if strict and failures → stop

---

## Stage 2 — THINK (Committee Setup + Parallel Expert Analysis)

**Goal:** Confirm the committee setup, then dispatch experts for independent analysis with evidence-backed position papers.

### Step 0: Committee Setup (ALWAYS — every `/gang think`)

Read `.gang/config.yaml`. Then use `AskUserQuestion`:

**If config already has active roles (i.e., a previous setup exists):**

- Header: "Committee Setup"
- Context: Show current setup:
  ```
  Current Committee:
    [on]  PM Lead ............. deep (sonnet)
    [on]  Market Researcher ... deep (sonnet)
    [off] UX Researcher ....... disabled
    [on]  Finance Analyst ..... deep (sonnet)
    [on]  Solutions Architect . deep (sonnet)
    [off] Business Strategist . disabled
    [off] Domain Expert ....... disabled
    [on]  CEO/CTO Advisor ..... deep (opus)

  Debate: selective, 2 rounds
  Mode: product_review
  ```
- Options:
  - "Keep current setup" — "Continue with the committee shown above"
  - "Full committee" — "Enable all 6 core agents + domain expert, deep mode"
  - "Lean committee" — "PM Lead + Solutions Architect + CEO/CTO only, light mode"
  - "Custom" — "Let me pick which agents to enable/disable and their weights"

**If no previous setup:**
- Options: "Full (default)", "Lean", "Custom"

**If "Custom" selected:**
For each agent, ask: enabled? weight (light/deep)? Then update `.gang/config.yaml`.

**After selection:**
1. Write updated roles to `.gang/config.yaml`
2. Update `state.json.active_agents` with list of enabled agent names

### Step 1: Check Prerequisites

Verify "init" is in `state.json.stages_completed`. If not → suggest `/gang init`.

### Step 2: Resolve Models for Each Agent

For each enabled agent in `config.roles`:
1. Get base model from `config.roles.{agent}.model`
2. Apply routing rules (manual / budget-adaptive / multi-provider) — see Model Routing section
3. Record resolved model + provider for each agent

### Step 3: Cost Pre-Check

If `config.cost.enabled` and `config.cost.budget_limit > 0`:
1. Estimate cost for all enabled agents at their resolved models
2. Add to current `state.json.cost.total_estimated_usd`
3. If over budget → warn/block per config thresholds

### Step 4: Dispatch All Experts in Parallel

For each **enabled** agent, dispatch using the Agent tool in a SINGLE message (parallel execution).

**Determine weight instruction:**
- If `config.roles.{agent}.weight` is `light`: add to prompt: "**Light Mode:** Keep your analysis to 500 words maximum. Skip detailed frameworks. Deliver: (1) Bottom line in 2 sentences, (2) Top 3 findings with evidence, (3) Key risk. No tables over 5 rows."
- If `deep`: standard full analysis.

**Determine model:**
- Use the resolved model from Step 2. Pass as the `model` parameter to the Agent tool (for Claude models).
- For external providers: write prompt to temp file, call external-dispatch.sh, read output.

**Agent prompt template (customize per agent):**

> Read the context brief at `{output_root}/context-brief.md`. You are participating in a Gang business committee evaluation.
>
> **Evidence & Assumptions Protocol:**
> 1. Read `{output_root}/evidence.json` — these are the ONLY trusted facts.
> 2. For every major claim in your position paper, cite `evidence_ids: [ev-001, ev-003]`.
> 3. If you make a claim NOT backed by evidence, register it as an assumption in `{output_root}/assumptions.json` with a validation plan. Use the next available `as-{NNN}` ID.
> 4. Reference `assumption_ids: [as-001]` for assumption-backed claims.
> 5. Never present assumptions as facts. Tag confidence: verified / medium / assumed.
>
> {weight_instruction}
>
> Produce your position paper following your agent instructions exactly. Write your output to `{output_root}/position-papers/{agent-name}.md`.
>
> Also read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md` — you will need it in the next stage.
>
> {For gang-ux-researcher only: Also produce all 9 UX deliverable files in `{output_root}/ux-deliverables/`. Read the Impeccable design rules at `{plugin_root}/skills/gang/references/impeccable-design-rules.md` and the Stitch template at `{plugin_root}/skills/gang/references/stitch-prompt-template.md`.
>
> **IMPORTANT — tag every deliverable file** with a metadata comment at the very top, before any content:
>
> ```
> <!-- ux:based-on
>   stage: think
>   plan: exploratory
>   assumption_ids: [as-001, as-003]   ← list every assumption this file depends on
>   scope_signals: [full-feature-set]  ← what scope assumptions are baked in
>   stable_if: assumption_ids hold + scope unchanged
> -->
> ```
>
> This tag lets the DELIVER stage identify exactly which files need updating without re-reading all 9.
> Files like personas.md and jobs-to-be-done.md will almost always be stable. Wireframes and stitch-instructions.md are scope-sensitive and often need a delta pass.}
>
> {For gang-domain-expert only: Read your domain profile at `{output_root}/domain-expert-profile.md` and adopt that persona.}

### Step 5: After Dispatch

Once all agents complete:
1. Verify all position papers exist in `{output_root}/position-papers/`
2. If UX Researcher was enabled: verify UX deliverables in `{output_root}/ux-deliverables/`
3. Record each agent's result in `state.json.agent_results`
4. Update cost tracking in `state.json.cost.stages.think`
5. Handle failures per Failure Handling config
6. Present summary to user: which experts completed, key headline from each

### Step 6: Validate & Update State

1. Run validation if enabled (evidence refs, file presence)
2. Update `state.json`: add "think" to `stages_completed`, set `current_stage` to "debate"
3. Show cost so far: "THINK stage cost: ~${X}. Total: ~${Y} / ${budget} ({Z}%)"

---

## Stage 3 — DEBATE (Cross-Review, Configurable Rounds)

**Goal:** Experts challenge each other's positions, revise based on feedback, surface conflicts — all evidence-backed.

### Step 0: Resolve Debate Mode

Read `config.debate`:
- If `debate.enabled: false` → skip debate entirely, go to SCORE
- `mode` determines Round 1 behavior:

| Mode | Round 1 Behavior |
|------|-----------------|
| `all-vs-all` | Every agent reviews every other agent's position |
| `selective` | Each agent only reviews targets listed in `selective_pairs` |
| `relevance-based` | Auto-determine: PM↔Market, Finance↔Architect, UX↔PM, Strategy↔Finance, Domain→All |
| `focused` | All agents debate only the topics in `focused_topics` |

- `max_rounds`: 1 = Round 1 only (no revision), 2 = full debate
- `round2_mode`: ALWAYS `all-vs-all` — every critiqued agent must respond

### Round 1: Isolation Review

Dispatch all **enabled** agents in parallel. Each agent's prompt:

> You are in Stage 3 Round 1 of the Gang debate. Read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md`.
>
> **Evidence & Assumptions Protocol:** Same as THINK stage — cite evidence_ids, register new assumptions.
>
> **Debate Mode: {mode}**
> {If selective: "You are reviewing ONLY: {list of target agents}"}
> {If focused: "Focus your critique on these topics: {focused_topics}"}
> {If relevance-based: "You are reviewing: {auto-determined targets based on agent role}"}
> {If all-vs-all: "Review ALL other position papers."}
>
> Read position papers in `{output_root}/position-papers/`. For each target expert's position, write a critique following the Round 1 format in the debate protocol.
>
> Apply the Executive Mentor pre-mortem pattern: "Imagine this fails in 12 months — why?"
>
> Write your complete review to `{output_root}/debate/round-1/{agent-name}-review.md`.

### Round 2: Debate & Revision (if `max_rounds >= 2`)

After Round 1 completes, dispatch all **critiqued** agents in parallel (round2_mode is always all-vs-all):

> You are in Stage 3 Round 2 of the Gang debate. Read the debate protocol at `{plugin_root}/skills/gang/references/debate-protocol.md`.
>
> **Evidence & Assumptions Protocol:** Same rules — cite evidence, register assumptions.
>
> Read your original position paper at `{output_root}/position-papers/{agent-name}.md`.
> Read ALL Round 1 reviews in `{output_root}/debate/round-1/`.
>
> Produce a revised position following the Round 2 format. You MUST address every critique directed at your position.
>
> Write to `{output_root}/debate/round-2/{agent-name}-revised.md`.

### Compile Debate Log

After the final round completes, compile `{output_root}/debate-log.md`:
- Extract resolved agreements, resolved-through-debate items, unresolved conflicts
- Extract stress-test results from Round 1 reviews
- Extract kill switches proposed by any expert
- Follow the debate log format in the debate protocol reference file

Present debate highlights to the user.

### Update State

1. Run validation if enabled
2. Update `state.json`: add "debate" to `stages_completed`, set `current_stage` to "score"
3. Update cost tracking

---

## Stage 4 — SCORE (Rubric-Anchored Plan Synthesis)

**Goal:** Synthesize 1-2 competing plans from the converged debate and score them with rubric anchoring and evidence linking.

### Step 1: Load Rubric

Read `{output_root}/score-rubric.json` (copied during INIT from default-score-rubric.json).

### Step 2: Synthesize Plans

Read all Round 2 revised positions (or Round 1 reviews if max_rounds=1) and the debate log. Identify:
- What the committee AGREES on (core of every plan)
- Where the committee DIVERGES (differences between plans)

Produce 1-2 competing plans.

### Step 3: Score Each Plan

Score on 5 dimensions (or 6 if Domain Expert enabled):

| Dimension | Description | Score Sources |
|-----------|-------------|--------------|
| Market Viability | Is there a real market? | Market Researcher + Business Strategist |
| User Desirability | Do users want this? | UX Researcher + PM Lead |
| Technical Feasibility | Can we build it? | Solutions Architect |
| Financial Viability | Does the math work? | Finance/Risk Analyst |
| Strategic Alignment | Does this fit strategy? | Business Strategist + PM Lead |
| Domain Fit *(if enabled)* | Industry realities? | Domain Expert |

**When `config.scoring.enabled` is true:**

For EACH dimension, produce a rubric-anchored scorecard entry:

```json
{
  "dimension": "technical_feasibility",
  "score": 7,
  "rubric_anchor": "7",
  "rubric_text": "{text from score-rubric.json for level 7}",
  "evidence_ids": ["ev-003", "ev-007"],
  "assumption_ids": ["as-002"],
  "justification": "{Why this score — minimum 20 chars}",
  "confidence": 0.8
}
```

**Rules:**
- `require_rubric_anchoring`: score MUST map to a rubric level (use nearest: 1/3/5/7/9/10)
- `require_evidence_linking`: each score MUST cite at least one evidence_id from evidence.json
- `require_assumption_linking`: if score depends on an assumption, cite the assumption_id

### Step 4: Output

Write `{output_root}/scored-plans.md` with the visual table format AND embed the structured scorecard JSON:

```markdown
# Gang Scored Plans

## Plan A: {name}
{Brief description}

| Dimension | Score | Rubric | Evidence | Assumptions | Confidence | Justification |
|-----------|-------|--------|----------|-------------|------------|---------------|
| Market Viability | {1-10} | "{rubric text}" | ev-001, ev-005 | as-001 | {0-1} | {reason} |
| ... | | | | | | |
| **Weighted Average** | **{score}** | | | | **{avg}** | |

### Strengths
- {key strength}

### Weaknesses
- {key weakness}

---

<!-- SCORECARD_JSON
{full scorecard JSON matching scorecard.schema.json}
-->
```

### Step 5: Validate & Update State

1. If validation enabled: verify all evidence_ids and assumption_ids referenced in scorecard actually exist
2. Update `state.json`: add "score" to `stages_completed`, set `current_stage` to "advise"
3. Present scored plans to the user with visual summary
4. Update cost tracking

---

## Stage 5 — ADVISE (CEO/CTO Advisory with Guardrails)

**Goal:** Final executive synthesis with Go/No-Go recommendation, subject to advisor guardrails.

### Step 1: Dispatch CEO/CTO Advisor

Use the Agent tool to dispatch `gang-ceo-cto-advisor` (runs on Opus for deepest reasoning):

> You are the CEO/CTO Advisor for the Gang business committee. This is Stage 5 — the final advisory.
>
> Read ALL of these files:
> - `{output_root}/context-brief.md`
> - `{output_root}/evidence.json` — the evidence ledger
> - `{output_root}/assumptions.json` — the assumptions ledger
> - All files in `{output_root}/position-papers/`
> - All files in `{output_root}/debate/round-2/` (or round-1 if max_rounds=1)
> - `{output_root}/debate-log.md`
> - `{output_root}/scored-plans.md`
> - `{output_root}/score-rubric.json`
> - `{output_root}/domain-expert-profile.md` (if it exists)
>
> **Evidence & Assumptions Protocol:** Your executive brief must cite evidence_ids for key claims. Review the assumptions ledger and flag unvalidated critical assumptions.
>
> **Advisor Guardrails:**
> {If config.scoring.advisor_guardrails.require_rubric_for_go: "You CANNOT issue GO unless all critical dimensions (Market Viability, Technical Feasibility, Financial Viability) have rubric-anchored scores."}
> {If config.scoring.advisor_guardrails.require_validation_plans: "You CANNOT issue GO if any critical/high-importance assumption lacks a validation plan."}
> {If config.scoring.advisor_guardrails.auto_conditional_on_unvalidated: "If there are unvalidated critical assumptions, automatically downgrade GO → CONDITIONAL-GO. State which assumptions must be validated before the GO becomes unconditional."}
>
> **Partial Failure Check:** Read `state.json.agent_results`. If any core agent (PM Lead, Finance Analyst, Solutions Architect) has `status: failed`:
> - State in the brief: "Analysis incomplete: missing {agent} perspective due to {provider} failure."
> - Degrade your overall confidence accordingly.
> - You CANNOT issue unconditional GO with missing core agent analysis.
>
> Produce your executive brief following your agent instructions exactly.
> Write to `{output_root}/executive-brief.md`.

### Step 2: Present Results

After the advisor completes:
1. Read `{output_root}/executive-brief.md`
2. Present the key findings:
   - **Verdict:** Go / No-Go / Conditional-Go
   - **Top 3 risks**
   - **Kill switches**
   - **Quick wins**
3. If UX deliverables exist: remind about Stitch instructions
4. If verdict is GO or CONDITIONAL-GO: suggest `/gang deliver`

### Step 3: Telemetry (when `config.telemetry.enabled`)

If `auto_prompt_postmortem` is true, generate `{output_root}/postmortem.md`:

```markdown
# Post-Mortem — {evaluation_name}

**Date:** {date}
**Session:** {session_id}
**Verdict:** {verdict}
**Mode:** {quality mode}
**Cost:** ~${total}

## 3-Month Check-In

### Was the verdict correct?
- [ ] Yes, we followed it and it was right
- [ ] Yes, but we didn't follow it
- [ ] No, we should have gone the other way
- [ ] Too early to tell

### Which assumptions were wrong?
| Assumption ID | Text | What Actually Happened |
|---|---|---|

### Which agent was most off-base?
| Agent | What They Got Wrong | Impact |
|---|---|---|

### What decision would you make differently?
{free text}
```

Tell the user: "A post-mortem template has been created at `{output_root}/postmortem.md`. Fill it in after 3 months to help calibrate future evaluations."

### Step 4: Update State

1. Run validation if enabled
2. Update `state.json`: add "advise" to `stages_completed`, set `current_stage` to "deliver" (if GO) or "complete" (if NO-GO)
3. Enter interactive Q&A mode

---

## Stage 6 — DELIVER (GO Package Generation)

When the user runs `/gang deliver`:

### Pre-Check

1. Read `{output_root}/state.json` — verify "advise" is in `stages_completed`
2. Read `{output_root}/executive-brief.md` — check the verdict
3. If verdict is **NO-GO**: inform the user. Suggest `/gang reinit` if conditions have changed.
4. If **GO** or **CONDITIONAL-GO**: proceed.

### Step 1: UX Delta Check (only when UX Researcher was enabled in THINK)

Before dispatching the deliverables writer, check whether UX deliverables need refinement.

**1a. Build the UX Change Brief**

Read the `ux:based-on` metadata comment at the top of each file in `{output_root}/ux-deliverables/` (first comment block only — do NOT read full file content). Then read `{output_root}/scored-plans.md`, `{output_root}/executive-brief.md`, and `{output_root}/assumptions.json`.

Generate `{output_root}/ux-change-brief.md`:

```markdown
# UX Change Brief

## What the Advisor Decided
- **Winning plan:** {plan name and key characteristics}
- **Features removed / descoped:** {list}
- **New constraints from advisor:** {e.g., "mobile-first only", kill switches that remove features}
- **CONDITIONAL-GO conditions affecting scope:** {any}

## Assumption Outcomes
| Assumption ID | Text | Outcome | UX Impact |
|---|---|---|---|
| as-001 | {text} | ✓ validated / ✗ failed / — unresolved | none / affects wireframes / affects personas |

## Delta Decision per File
| File | Stable? | Reason |
|------|---------|--------|
| personas.md | ✓ stable | User archetypes don't change with plan selection |
| jobs-to-be-done.md | ✓ stable | Jobs are independent of plan |
| user-journeys.md | check | Update only if a descoped feature removes a critical flow |
| information-architecture.md | check | Update if nav items removed |
| wireframes.md | check | Scope changes affect screen inventory |
| design-tokens.md | ✓ stable | Tokens are plan-independent |
| interaction-patterns.md | ✓ stable | Patterns are plan-independent |
| accessibility-notes.md | ✓ stable | WCAG requirements don't change with plan |
| stitch-instructions.md | check | Must reflect final feature set exactly |

## Files Requiring Delta Pass
{list only the files that need updating — typically 1-3 out of 9}
```

**1b. Decide: delta pass or skip**

- **0 files need updating** → skip UX delta dispatch. Log: "UX deliverables stable — no delta pass needed."
- **1-3 files need updating** → dispatch UX Researcher in Delta Mode
- **4+ files need updating** → dispatch UX Researcher in Delta Mode with full context note

**1c. Dispatch UX Researcher in Delta Mode (when needed)**

> You are the UX Researcher returning for a **surgical delta pass** at the DELIVER stage.
> You already produced the full UX deliverables during THINK. Most of that work is still valid.
> Your ONLY job is to update the files listed under "Files Requiring Delta Pass" in `{output_root}/ux-change-brief.md`.
>
> Read:
> - `{output_root}/ux-change-brief.md` — what changed and which files need updating
> - `{output_root}/executive-brief.md` — the final verdict and constraints
> - `{output_root}/scored-plans.md` — the winning plan
> - Each file listed under "Files Requiring Delta Pass" (full content)
>
> For each file requiring a delta pass:
> 1. Read the existing file fully
> 2. Apply only the changes driven by the change brief — do not rewrite sections that remain valid
> 3. Update the `ux:based-on` metadata tag: set `stage: deliver`, update `plan:` to the winning plan name
> 4. Overwrite the file in `{output_root}/ux-deliverables/`
>
> For files NOT listed: do NOT read them, do NOT touch them.
> Do NOT produce a position paper. Do NOT re-read evidence.json or context-brief.md unless a specific delta requires it.
> Be surgical — the goal is minimum tokens, maximum precision.

### Step 2: Dispatch Deliverables Writer

Once the UX delta pass is complete (or skipped), dispatch `gang-deliverables-writer`:

> You are the Deliverables Writer for the Gang business committee. Generate the GO Package.
>
> Read ALL committee artifacts:
> - `{output_root}/context-brief.md`
> - `{output_root}/evidence.json`
> - All files in `{output_root}/position-papers/`
> - All files in `{output_root}/debate/round-2/`
> - `{output_root}/debate-log.md`
> - `{output_root}/scored-plans.md`
> - `{output_root}/executive-brief.md`
> - `{output_root}/domain-expert-profile.md` (if it exists)
> - All files in `{output_root}/ux-deliverables/` (now refined for the winning plan)
> - `{output_root}/ux-change-brief.md` (if it exists — summarises what UX changed at DELIVER)
>
> Generate all 6 documents following your agent instructions. Write to `{output_root}/go-package/`.

### After Dispatch

1. Verify all 6 documents exist in `{output_root}/go-package/`
2. Present a summary to the user
3. Update `state.json`: add "deliver" to `stages_completed`, set `current_stage` to "complete"

---

## Status Command

When the user runs `/gang status`:

1. Read `{output_root}/state.json` and `.gang/config.yaml`
2. Present:

```
Gang Committee Status
━━━━━━━━━━━━━━━━━━━━━━━━
Session: {session_id}
Version: 1.3.0
Mode: {quality_mode}
Evaluation: {type} — {name}

Committee ({N} active):
  [{on/off}] PM Lead ............. {weight} ({model})
  [{on/off}] Market Researcher ... {weight} ({model/provider})
  [{on/off}] UX Researcher ....... {weight} ({model})
  [{on/off}] Finance Analyst ..... {weight} ({model/provider})
  [{on/off}] Solutions Architect . {weight} ({model/provider})
  [{on/off}] Business Strategist . {weight} ({model})
  [{on/off}] Domain Expert ....... {weight} ({model})
  [{on/off}] CEO/CTO Advisor ..... {weight} ({model})

Debate: {mode} · {max_rounds} rounds
Evidence: {N} entries · {M} assumptions tracked
Validation: {strict/relaxed} ({passing/failing})

[{status}] INIT ........... ${cost}  {validation}
[{status}] THINK .......... ${cost}  {validation} ({N}/{M} agents, {F} failures)
[{status}] DEBATE ......... ${cost}
[{status}] SCORE .......... ${cost}
[{status}] ADVISE ......... ${cost}
[{status}] DELIVER ........ ${cost}

Cost: ~${total} / ${budget} budget ({%})

Next: Run /gang {next_command} to continue
```

---

## Config Command

When the user runs `/gang config`:

1. Read `.gang/config.yaml`
2. Present key settings in a readable format
3. Tell the user: "Edit `.gang/config.yaml` to change settings. Changes take effect on the NEXT stage run."

---

## Evaluations Command

When the user runs `/gang evaluations`:

1. List all directories in `.gang/features/` and `.gang/projects/`
2. For each, read `state.json` and show: name, type, current_stage, verdict (if available), date
3. Show flat evaluation if `.gang/state.json` exists at root level

```
Gang Evaluations
━━━━━━━━━━━━━━━━
Features:
  1. stock-details   Stage: complete  Verdict: CONDITIONAL-GO  2026-03-28
  2. portfolio-view   Stage: think     Verdict: —              2026-03-30

Projects:
  1. mobile-app      Stage: advise    Verdict: GO             2026-03-25

Flat: (none)
```

---

## Validate Command

When the user runs `/gang validate`:

Run `bash {plugin_root}/scripts/validate-gang.sh {output_root}` (when available).

Or perform inline validation:
1. Validate `evidence.json` against `{plugin_root}/schemas/evidence.schema.json`
2. Validate `assumptions.json` against `{plugin_root}/schemas/assumptions.schema.json`
3. Validate `state.json` against `{plugin_root}/schemas/state.schema.json`
4. Check all `evidence_ids` referenced in position papers exist in evidence.json
5. Check all `assumption_ids` referenced exist in assumptions.json
6. Check required files exist for each completed stage
7. Check position papers have required section headings

Print report with pass/fail per check.

---

## REINIT Command

When the user runs `/gang reinit`:

### Steps

1. **Check state:** Read `{output_root}/state.json` — verify it exists. If not → suggest `/gang init`.
2. **Preserve session:** Keep the same `session_id`.
3. **Re-run INIT Steps 2-6:** Execute the full INIT flow but:
   - Present existing answers as context: "Last time you said {X} — still accurate?"
   - Allow changing domain expert preference
   - Re-populate evidence.json (merge with existing or replace)
4. **Overwrite artifacts:** Replace context-brief.md, competitive-scan.md, domain-expert-profile.md.
5. **Reset downstream stages:** Update state.json:
   ```json
   {
     "stages_completed": ["init"],
     "current_stage": "think",
     "reinit_count": "{previous + 1}",
     "last_reinit": "{ISO-8601 timestamp}"
   }
   ```
6. **Inform:** "Context refreshed. Downstream stages reset. Run `/gang think` to continue."

---

## Error Handling

- If an agent fails to produce output: follow Failure Handling config (retry → fallback → mark failed)
- If `{output_root}/state.json` doesn't exist: suggest `/gang init`
- If a stage is run out of order: show which prerequisites are missing
- If the user wants to restart a stage: warn about overwriting existing output

## Token Budget Awareness

Mitigations:
- Position papers: capped at 1500 words (deep) or 500 words (light) — tables excluded
- The CEO/CTO Advisor gets a SUMMARY of debate, not raw Round 1 reviews
- UX deliverables are written to separate files, not inlined
- Each agent reads only what it needs for its current stage
- Light mode agents skip detailed frameworks, deliver bottom-line + top findings only
