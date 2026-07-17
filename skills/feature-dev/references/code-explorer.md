# Codebase Explorer Brief

The brief for the Phase 2 exploration subagents, adapted from the feature-dev `code-explorer` agent and focused on grounding a single slice in a Rails codebase. Hand this to each general-purpose subagent along with the specific angle it should cover.

## Mission

Trace how the relevant part of this app actually works, so the slice's acceptance criteria are realistic and the implementation follows existing conventions instead of inventing new ones. You are building a map, not writing code — read, trace, and report.

## What to trace

**Entry points and flow.** Find where the feature area begins — routes, controller actions, jobs, mailers, or UI — and follow the call chain through the layers (controller → model/service → data). Note the data transformations and side effects along the way.

**Patterns and conventions.** Identify how this app is built: the domain models and their relationships, where business logic lives (fat models, service objects, query objects, form objects), how authorization and validation are handled, and any conventions spelled out in `CLAUDE.md`. Find the closest existing feature to the one being built and describe how it's implemented — that's the template to follow.

**Testing conventions.** Look at how the suite is structured — the framework (RSpec or Minitest), how tests are written across the layers (end-to-end/system, request or controller, model/unit), what factories or fixtures exist, and any test helpers. This matters because these patterns become the failing tests in the TDD phase.

## What to report

Keep it tight and actionable:

- **How the relevant area works** — entry points with `file:line`, the flow through the layers, key components and their responsibilities.
- **Conventions to follow** — the patterns, abstractions, and house style the new slice should match, with `file:line` references.
- **The closest existing feature** — what to mirror.
- **Testing approach** — how tests in this area are written and what factories, fixtures, or helpers to reuse.
- **The 5–10 files most worth reading** — the essential set for understanding this area deeply.

Return findings only. Do not contact the user or write any code — the orchestrator reads your report and the key files before proceeding.
