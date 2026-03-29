<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Plugin-7C3AED?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTEyIDJMMyA3djEwbDkgNSA5LTVWN2wtOS01eiIgZmlsbD0id2hpdGUiLz48L3N2Zz4=" alt="Claude Code Plugin">
  <img src="https://img.shields.io/badge/version-1.2.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/agents-7+1_optional-orange?style=for-the-badge" alt="Agents">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
</p>

<h1 align="center">🏛️ Gang</h1>
<h3 align="center">Multi-Agent Business Committee for Claude Code</h3>

<p align="center">
  <strong>One command. Seven experts. One verdict.</strong><br/>
  Turn your IDE into a boardroom — 6 experts + 1 optional Domain Expert analyze, debate, and score your product idea,<br/>
  then a CEO/CTO advisor delivers a Go/No-Go recommendation with build-ready deliverables.
</p>

<p align="center">
  <code>/gang run</code>
</p>

---

## ⚡ Quick Start

```bash
# 1️⃣ Install the plugin
claude plugin install https://github.com/ebnrdwan/GangPlugin

# 2️⃣ Run on any project
/gang run
```

---

## 🔍 The Gap

AI tools are great at **building** — but nobody's asking **whether you should build it**.

> 💡 Engineers ship features nobody asked for. Founders chase markets that don't exist.
> Teams build before validating. **The cost isn't the code — it's the months spent building the wrong thing.**

Gang embeds a complete business evaluation pipeline in your development environment:

- 🔬 **Deep codebase understanding** before asking you anything
- 🌐 **Automated competitive research** via web search
- ⚔️ **Multi-perspective adversarial debate** (not single-agent advice)
- 📊 **Quantified scoring** across market, UX, feasibility, finance, and strategy
- 🎨 **Google Stitch-ready UI specs** that flow from strategic decisions
- 🚨 **Kill switches** — explicit checkpoints to exit early if assumptions break

---

## 🔄 How It Works

```mermaid
graph LR
    A["🔍 INIT<br/>Scan + Research"] --> B["🧠 THINK<br/>6-7 Experts"]
    B --> C["⚔️ DEBATE<br/>2 Rounds"]
    C --> D["📊 SCORE<br/>5-6 Dimensions"]
    D --> E["👔 ADVISE<br/>Go / No-Go"]
    E --> F["📦 DELIVER<br/>GO Package"]

    style A fill:#6366f1,stroke:#4f46e5,color:#fff
    style B fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style C fill:#a855f7,stroke:#9333ea,color:#fff
    style D fill:#c084fc,stroke:#a855f7,color:#fff
    style E fill:#d946ef,stroke:#c026d3,color:#fff
    style F fill:#f97316,stroke:#ea580c,color:#fff
```

Run `/gang status` at any point to track progress:

```
🏛️ Gang Committee Status
━━━━━━━━━━━━━━━━━━━━━━━━
Session: gang-20260329-143022
Started: 2026-03-29

[✓] Stage 1: INIT — Context brief ready
[✓] Stage 2: THINK — 6/6 position papers complete
[→] Stage 3: DEBATE — Round 1 complete, Round 2 in progress
[ ] Stage 4: SCORE — Not started
[ ] Stage 5: ADVISE — Not started

Artifacts:
  .gang/context-brief.md .............. ✓
  .gang/competitive-scan.md ........... ✓
  .gang/position-papers/ .............. 6 files ✓
  .gang/ux-deliverables/ .............. 9 files ✓
  .gang/debate/round-1/ ............... 6 files ✓
  .gang/debate/round-2/ ............... 0 files
  .gang/debate-log.md ................. pending
  .gang/scored-plans.md ............... pending
  .gang/executive-brief.md ............ pending

Next: Run /gang debate to continue
```

---

## 👥 The Committee

```mermaid
graph TB
    subgraph "Stage 2 — Parallel Analysis (Sonnet)"
        PM["📋 PM Lead<br/>RICE · MVP · PRD"]
        MR["🌐 Market Researcher<br/>TAM/SAM/SOM · SWOT"]
        UX["🎨 UX Researcher<br/>Personas · Stitch"]
        FA["💰 Finance Analyst<br/>DCF · SaaS Metrics"]
        SA["🏗️ Solutions Architect<br/>Feasibility · TCO"]
        BS["📈 Business Strategist<br/>GTM · Moat · Pricing"]
        DE["🔬 Domain Expert<br/>Industry SME (Optional)"]
    end

    subgraph "Stage 5 — Final Verdict (Opus)"
        CEO["👔 CEO/CTO Advisor<br/>Go / No-Go"]
    end

    PM --> CEO
    MR --> CEO
    UX --> CEO
    FA --> CEO
    SA --> CEO
    BS --> CEO
    DE -.-> CEO

    style PM fill:#3b82f6,stroke:#2563eb,color:#fff
    style MR fill:#06b6d4,stroke:#0891b2,color:#fff
    style UX fill:#22c55e,stroke:#16a34a,color:#fff
    style FA fill:#eab308,stroke:#ca8a04,color:#fff
    style SA fill:#d946ef,stroke:#c026d3,color:#fff
    style BS fill:#ef4444,stroke:#dc2626,color:#fff
    style DE fill:#f97316,stroke:#ea580c,color:#fff
    style CEO fill:#7c3aed,stroke:#6d28d9,color:#fff
```

| Expert | Focus |
|--------|-------|
| 📋 **PM Lead** | RICE prioritization, MVP scope, requirements |
| 🌐 **Market Researcher** | TAM/SAM/SOM, competitive analysis, SWOT |
| 🎨 **UX Researcher** | Personas, journeys, design tokens, Stitch instructions |
| 💰 **Finance/Risk Analyst** | DCF, SaaS metrics, risk matrix, scenario modeling |
| 🏗️ **Solutions Architect** | Feasibility, architecture, build-vs-buy TCO |
| 📈 **Business Strategist** | GTM strategy, business model, competitive moat |
| 🔬 **Domain Expert** *(optional)* | Industry SME — regulatory, benchmarks, domain-specific risks |
| 👔 **CEO/CTO Advisor** | Go/No-Go verdict, kill switches, implementation roadmap |

---

## 📖 Full Documentation

See **[gang/README.md](gang/README.md)** for:

- 📋 Detailed stage breakdown with examples
- 🎯 6 real-world use cases
- 📁 Output artifacts reference
- 🎨 Google Stitch & Impeccable design integration
- ⚖️ Comparison with alternatives
- 🧰 Expert frameworks reference

---

## 📄 License

MIT — use it, fork it, build on it.
