# Gang Debate Protocol

Adapted from C-Level Skills `board-meeting` (3-phase debate format) and Executive Mentor
(`/em:challenge` + `/em:stress-test` adversarial patterns). This protocol governs Stage 3 of
the Gang workflow.

---

## Overview

The debate runs 2 rounds, following the Board Meeting's 3-phase structure:
1. **Framing** — completed in Stage 2 (each expert's position paper IS their framing)
2. **Isolation** — Round 1: independent critique without groupthink
3. **Debate** — Round 2: respond to critiques, revise positions, surface conflicts

**Note:** If the Domain Expert is enabled (`state.json.domain_expert_enabled: true`), they participate as a 7th agent in both rounds. The Domain Expert brings domain-specific critiques that generalists cannot — regulatory gaps, incorrect benchmarks, false differentiators, and industry-blind assumptions.

---

## Round 1: Isolation Review

**Goal:** Each expert independently reviews ALL other position papers and writes critiques.
No expert sees another expert's critiques during this round (prevents anchoring bias).

### Input
Each agent reads:
- `.gang/context-brief.md` (original brief for reference)
- ALL files in `.gang/position-papers/` (6 or 7 position papers depending on domain expert)

### Output
Each agent writes to: `.gang/debate/round-1/{agent-name}-review.md`

### Critique Format

```markdown
# {Agent Role} — Round 1 Review

## Review of {Other Agent Role}'s Position

### Strengths
- {What they got right — be specific, cite their evidence}

### Challenges

#### Assumption Challenge 1: "{quoted assumption}"
- **Confidence:** {High | Medium | Low | Unknown}
- **Impact if wrong:** {Critical | High | Medium | Low}
- **Counter-evidence:** {Why this assumption might be wrong — cite data, precedent, or logic}
- **Recommendation:** {Validate by..., Hedge by..., or Accept as-is}

#### Assumption Challenge 2: "{quoted assumption}"
...

### Gaps
- {What they missed that matters — must cite WHY it matters, not just that it's missing}

### Conflicts with My Position
- **On {topic}:** They say {X}, I say {Y}, because {reason}. This must be resolved.

---

## Review of {Next Agent Role}'s Position
...

---

## Cross-Cutting Observations
- {Patterns across multiple positions — agreements, contradictions, blind spots}

## Top 3 Assumptions to Stress-Test
1. "{assumption}" — held by {agent(s)} — test by {method}
2. "{assumption}" — held by {agent(s)} — test by {method}
3. "{assumption}" — held by {agent(s)} — test by {method}
```

### Critique Rules
1. **Be specific** — "This is wrong" is not a critique. "This assumes X, but Y evidence suggests otherwise" is.
2. **Cite evidence** — Every challenge must reference data, precedent, market signal, or logic.
3. **Acknowledge strengths** — Critiques without acknowledging what's right are adversarial, not helpful.
4. **Flag conflicts explicitly** — If your position contradicts theirs, name it. Don't bury it.
5. **Propose, don't just criticize** — Every challenge should include a recommendation.
6. **Tag confidence** — Use 🟢 verified, 🟡 medium, 🔴 assumed on your own critiques too.

### Domain Expert Critique Focus (when enabled)

The Domain Expert's Round 1 review should specifically target:
- **PM Lead:** Are MVP features actually table-stakes in this industry? Are industry-mandatory features missing?
- **Market Researcher:** Is TAM/SAM sizing correct for this specific industry segmentation? Are industry-specific competitive dynamics reflected?
- **UX Researcher:** Do personas reflect real industry user behavior and workflows?
- **Finance Analyst:** Are benchmarks (CAC, LTV, margins, conversion) appropriate for this specific industry? Generic SaaS benchmarks often don't apply.
- **Solutions Architect:** Is compliance infrastructure accounted for? Industry-specific technical requirements (data licensing, protocols, certifications)?
- **Business Strategist:** Is the GTM strategy realistic for this industry's sales cycles, channels, and partnerships?

Other experts reviewing the Domain Expert should challenge:
- Whether the regulatory constraints cited actually apply to THIS specific product
- Whether the industry benchmarks are current and from reliable sources
- Whether the "table-stakes" classification is accurate or overly conservative

---

## Round 2: Debate & Revision

**Goal:** Each expert reads ALL Round 1 critiques (including critiques of their own position),
then produces a revised position that addresses every critique directed at them.

### Input
Each agent reads:
- Their original position paper (`.gang/position-papers/{agent-name}.md`)
- ALL Round 1 reviews (`.gang/debate/round-1/*.md`)
- The debate protocol (this file) for format reference

### Output
Each agent writes to: `.gang/debate/round-2/{agent-name}-revised.md`

### Revised Position Format

```markdown
# {Agent Role} — Revised Position

## Changes Made

### Accepted Critiques
| # | Critique From | Issue | My Response | Impact on Position |
|---|---|---|---|---|
| 1 | {Agent} | {brief issue} | Accepted — revised {section} | {High/Medium/Low} |
| 2 | {Agent} | {brief issue} | Accepted — revised {section} | {High/Medium/Low} |

### Rejected Critiques (with reasoning)
| # | Critique From | Issue | Why Rejected |
|---|---|---|---|
| 1 | {Agent} | {brief issue} | {Specific reason — NOT "I disagree"} |

### New Information Incorporated
- {Insights from other positions that strengthened or changed my analysis}

---

## Revised Position

{Updated position paper — same structure as original, but revised based on debate.
Mark changed sections with [REVISED] tag.}

---

## Unresolved Conflicts

| Topic | My Position | Opposing Position(s) | Why It Matters |
|---|---|---|---|
| {topic} | {my stance} | {their stance + who holds it} | {impact on final recommendation} |

## Confidence Update
- Overall confidence in my position: {Higher / Same / Lower} — because {reason}
- Key risk that emerged from debate: {description}
```

### Revision Rules
1. **Address every critique** — Either accept it (and show the revision) or reject it (and explain why).
   Ignoring a critique is not allowed.
2. **Show your work** — Don't just say "revised." Show what changed and why.
3. **Preserve dissent** — If you still disagree after considering the critique, that's fine.
   Log it in "Unresolved Conflicts" so the CEO/CTO Advisor can weigh in.
4. **Update confidence** — Your confidence should change if the debate revealed new information.
5. **No new topics** — This round is for responding to critiques, not introducing new analysis.
   Save new insights for the "New Information Incorporated" section.

---

## Adversarial Layer: Executive Mentor Patterns

Applied during Round 1 by ALL agents as part of their critique methodology.

### Pre-Mortem Challenge (from `/em:challenge`)

For each position paper, ask:
> "Imagine this recommendation fails in 12 months — why?"

Then work backwards to identify:
1. **Core assumptions** extracted from the position (tag each: High/Medium/Low/Unknown confidence)
2. **Vulnerability map** (what could go wrong, categorized by severity)
3. **Dependency chains** (what must be true for this to work)
4. **Kill switches** — propose conditions:
   - "Continue if {condition} by Day 30"
   - "Kill if {condition} by Day 60"
   - "Pivot if {condition} by Day 90"

### Stress-Test (from `/em:stress-test`)

For the top 3 cross-cutting assumptions identified in Round 1:
1. **Isolate** the assumption (make it specific and testable)
2. **Find counter-evidence** (who failed with this assumption? what data contradicts it?)
3. **Model downside:**
   - Base case (as proposed)
   - Bear case (-30% on key metric)
   - Stress case (-50%)
   - Catastrophic case (-80%)
4. **Key question:** "Does the business/product survive at -50%?"
5. **Propose hedge:** validation method + contingency + early warning signal

---

## Debate Log

After Round 2, the orchestrator compiles `.gang/debate-log.md` from all revised positions:

```markdown
# Gang Debate Log — Session {session_id}

## Resolved Agreements
| Topic | Consensus Position | Agreed By |
|---|---|---|
| {topic} | {what everyone agrees on} | All / {specific agents} |

## Resolved Through Debate
| Topic | Original Conflict | Resolution | Changed By |
|---|---|---|---|
| {topic} | {Agent A said X, Agent B said Y} | {Final position} | {Who changed their mind} |

## Unresolved Conflicts (Escalated to CEO/CTO Advisor)
| Topic | Position A | Held By | Position B | Held By | Impact |
|---|---|---|---|---|---|
| {topic} | {stance} | {agents} | {counter-stance} | {agents} | {Critical/High/Medium} |

## Stress-Test Results
| Assumption | Base | Bear (-30%) | Stress (-50%) | Survives? |
|---|---|---|---|---|
| {assumption} | {outcome} | {outcome} | {outcome} | {Yes/No/Conditional} |

## Kill Switches Proposed
| Condition | Timeframe | Action |
|---|---|---|
| {condition} | Day 30 | Continue / Investigate |
| {condition} | Day 60 | Continue / Kill |
| {condition} | Day 90 | Continue / Pivot |
```

---

## Principles

1. **Disagree and commit** — Debate hard, but once the advisory is issued, the recommendation is unified.
2. **Dissent is preserved, not suppressed** — The CEO/CTO Advisor sees ALL unresolved conflicts.
3. **Evidence over opinion** — "I feel" is not a valid argument. "Data shows" or "Precedent suggests" is.
4. **Specificity over generality** — "The market is competitive" is useless. "3 funded competitors raised $50M+ in 2025 targeting the same ICP" is actionable.
5. **Confidence is honest** — If you're guessing, tag it 🔴. The Advisor needs to know what's solid vs assumed.
