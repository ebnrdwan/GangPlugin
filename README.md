# Gang Plugin for Claude Code

> **One command. Six experts. One verdict.**

A Claude Code plugin that turns your IDE into a boardroom. Six domain experts independently analyze your product idea, debate each other through structured adversarial review, and a CEO/CTO advisor delivers a scored Go/No-Go recommendation — all from a single command.

## Quick Start

```bash
# Add the marketplace
claude plugin marketplace add https://github.com/ebnrdwan/GangPlugin

# Install
claude plugin install gang

# Run on any project
/gang run
```

## What It Does

```
/gang init    →  Scans your codebase + researches competitors + asks smart questions
/gang think   →  6 experts analyze independently in parallel
/gang debate  →  2 rounds of structured cross-review + stress-testing
/gang score   →  Plans scored on 5 dimensions (1-10 + confidence %)
/gang advise  →  CEO/CTO delivers Go/No-Go with kill switches + roadmap
```

## The Gap It Fills

AI tools are great at building — but nobody's asking **whether you should build it**.

Gang embeds a complete business evaluation pipeline in your development environment:
- **Deep codebase understanding** before asking you anything
- **Automated competitive research** via web search
- **Multi-perspective adversarial debate** (not single-agent advice)
- **Quantified scoring** across market, UX, feasibility, finance, and strategy
- **Google Stitch-ready UI specs** that flow from strategic decisions
- **Kill switches** — explicit checkpoints to exit early if assumptions break

## The Committee

| Expert | Focus |
|--------|-------|
| PM Lead | RICE prioritization, MVP scope, requirements |
| Market Researcher | TAM/SAM/SOM, competitive analysis, SWOT |
| UX Researcher | Personas, journeys, design tokens, Stitch instructions |
| Finance/Risk Analyst | DCF, SaaS metrics, risk matrix, scenario modeling |
| Solutions Architect | Feasibility, architecture, build-vs-buy TCO |
| Business Strategist | GTM strategy, business model, competitive moat |
| CEO/CTO Advisor | Go/No-Go verdict, kill switches, implementation roadmap |

See [gang/README.md](gang/README.md) for full documentation, examples, and use cases.

## License

MIT
