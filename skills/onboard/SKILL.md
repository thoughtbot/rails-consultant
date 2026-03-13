---
name: onboard
description: Onboard to a new codebase — explore architecture, conventions, key models, infrastructure, test health, and risks. The 30,000-foot view before touching anything.
argument-hint: "[optional focus area]"
disable-model-invocation: true
context: fork
agent: Explore
---

## Behavior

Start the research immediately. If `$ARGUMENTS` specifies a focus area, weight the exploration toward that area while still covering the full picture. This is a thorough exploration — take the time to get the picture right.

### Step 1: The Big Picture

Explore the codebase to build a high-level understanding:

- **Gemfile** — what's the stack? Database, background jobs, authentication, authorization, payments, search, caching, API, front-end framework. The Gemfile tells you more about an app than any README.
- **config/routes.rb** — how big is the surface area? How many controllers, namespaces, API versions? Is it a monolith, API-only, or hybrid?
- **app/ directory structure** — what directories exist beyond the Rails defaults? `services/`, `operations/`, `forms/`, `queries/`, `decorators/`, `policies/`? The directory structure reveals the team's architectural choices.
- **db/schema.rb** — how many tables? What are the key models? Look at relationships, indexes, and column types for the core domain.
- **config/** — environment-specific configuration, initializers, credentials setup. What external services is this app connected to?
- **README.md / docs/** — if they exist, read them. But verify against the code — docs drift.

### Step 2: Architecture and Conventions

Dig into the patterns the codebase uses:

- **ApplicationController / ApplicationRecord / ApplicationJob** — what do the base classes set up? Authentication, error handling, logging, default scopes?
- **Concerns and shared modules** — what's been extracted? Are concerns used well (shared behaviour) or as junk drawers?
- **How is business logic organized?** — in models, service objects, operations, or somewhere else? Is there a consistent pattern or is it mixed?
- **How are tests structured?** — RSpec or Minitest? What's the ratio of unit to integration to system tests? Run a quick `find app/models -name "*.rb" | wc -l` vs `find spec/models -name "*_spec.rb" | wc -l` to gauge coverage breadth.
- **Front-end approach** — Hotwire/Turbo, React, Vue, API-only? Import maps, esbuild, Webpack? What serves the HTML?

### Step 3: Git History and Health

- `git log --oneline -30` — what's the recent activity? Velocity, commit style, who's contributing.
- `git shortlog -sn --since="3 months ago"` — who are the active contributors?
- `git log --oneline --since="1 month ago" -- db/migrate/` — recent schema changes signal active areas.
- Look for: large commits that might be "big bang" changes, revert patterns, areas with lots of recent churn.

### Step 4: Risk and Debt Signals

Look for the things that will bite you:

- **Test suite health** — is there a CI config? Can you infer whether tests pass? Are there skipped or pending tests?
- **Ruby and Rails version** — how current? Are there deprecation warnings likely?
- **Dependency health** — old gems, gems with known issues, gems that are no longer maintained?
- **Code hotspots** — files with the most churn (frequent changes) are often the most fragile: `git log --format=format: --name-only --since="6 months ago" | sort | uniq -c | sort -rn | head -20`
- **TODOs and FIXMEs** — grep for them. They're a map of acknowledged debt.
- **Missing indexes, N+1 signals** — check for `has_many` without corresponding indexes, or patterns that suggest eager loading isn't happening.

### Step 5: Report

Deliver the findings in this order:

**What this application is** — one paragraph. What it does, who it's for, how big it is. Written so a non-technical stakeholder could understand it.

**The stack** — a concise list: Ruby/Rails version, database, background jobs, authentication, front-end, key gems, deployment (if discoverable).

**Architecture and conventions** — how business logic is organized, what patterns are used, where the team's conventions are strong and where they're inconsistent. Name the patterns by name (service objects, form objects, etc.).

**The domain** — the core models and their relationships. Focus on the 5–10 models that matter most. A brief description of each and how they relate.

**Active areas** — what's been changing recently, based on git history. Where is the team spending time?

**Risk and debt** — what you found that could cause problems. Be specific: outdated dependencies, missing test coverage, code hotspots, acknowledged TODOs. Not a scare list — a prioritized assessment of what matters.

**Questions for the team** — 5–10 questions to ask stakeholders or the development team. These should be things the code alone can't answer:

- Questions about **business context** — "What's the most important user flow in this application?" "What part of the system are you most worried about?" "What's the feature or area users complain about most?"
- Questions about **technical decisions** — "Why was [pattern/gem/approach] chosen for [concern]?" "Is the team actively migrating away from anything?" "Are there areas of the code you avoid touching?"
- Questions about **process and team** — "How do features get from idea to production?" "Who knows the [specific area] best?" "What does your deployment process look like?"
- Questions about **priorities** — "If you could fix one thing about this codebase, what would it be?" "What's the biggest technical risk to the business right now?"

Tailor the questions to what the codebase exploration surfaced — if you found something unusual or concerning, ask about it specifically. Generic questions are less useful than "I noticed X — can you tell me the history behind that?"

---

## Output Format

Clear headings, concise prose, file paths for every reference. This is the document you'd want on day one of an engagement — useful as a reference for the duration of the project.

## Tone

Thorough but efficient. You're building a mental map, not writing an audit. Report what matters, skip what doesn't, and flag what you couldn't determine from code alone — that's what the questions are for.
