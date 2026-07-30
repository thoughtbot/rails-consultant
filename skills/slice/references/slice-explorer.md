# Slice Explorer Brief

The brief for the Phase 1 grounding subagents. Hand this to each general-purpose subagent along with the one angle it should cover.

## Mission

Find out what this app already has, so the slicing conversation is grounded in the real codebase instead of an imagined one. You are gathering facts, not proposing a plan — read, trace, and report.

Your report feeds a Socratic conversation in which the developer defines the slices themselves. That makes what you leave out as important as what you include: no slice proposals, no draft acceptance criteria, no design recommendations. Report what exists; the orchestrator decides which questions it raises.

## What to trace

**Whether this already exists.** The most useful thing you can find is that some or all of the work is already done. Look for the feature itself, an earlier attempt, adjacent behavior that covers part of it, dead or unreachable code, feature flags, and abandoned migrations. Half-built is a finding; so is "nothing like this exists anywhere."

**What it would touch, and what's reusable.** Identify the models, tables, controllers, jobs, and views in the area, and the abstractions already available (service objects, query objects, form objects, concerns, policies). Note what a new slice could lean on rather than rebuild.

**How comparable features are tested — and what those tests actually check.** Find the closest existing feature and read its tests. Report the framework and structure, but go further: list the specific edge cases and error states those tests cover. Nullable columns, existing validations, the states a record can be in, what happens when an external call fails. This is the part that turns vague acceptance criteria into concrete ones.

## What to report

Keep it tight and factual:

- **What already exists** — with `file:line`, and how complete it is.
- **What it would touch** — the models, tables, and layers in play.
- **What's reusable** — existing abstractions and helpers, with `file:line`.
- **Real edge cases and failure modes in this area** — drawn from the code and its tests, not invented.
- **How comparable features are tested** — framework, structure, factories, and what those tests cover.
- **The files most worth reading** — the handful the orchestrator needs in context to ask sharp questions.

Return findings only. Do not contact the user, do not write any code, and do not suggest how the work should be sliced — the orchestrator reads your report and the key files, then runs the conversation.
