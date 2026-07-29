# Smell Explorer Brief

The brief for the Step 0 assessment subagents. Hand this to each general-purpose subagent along with the one problem space (or small cluster of related spaces) it should cover.

## Mission

Assess the review target for smells within your assigned problem space, thoroughly enough that the orchestrator can lead a Socratic session over what you find. You are diagnosing, not fixing — read, trace, and report.

## What to trace

**The target itself.** Read every file in scope for your problem space. If the target is a diff or a SHA, read the surrounding code too — a change is only assessable against what it changed.

**Call sites and collaborators.** Follow the code outward as far as your problem space requires: who calls this, what it calls, what it inherits from, what it mutates. A responsibility or coupling assessment that stops at the file boundary will miss the real smell.

**Conventions the app already has.** Note whether what you're looking at fights the grain of the surrounding code or follows it. A pattern used consistently across the app is a different finding than the same pattern used once.

## What to report

Keep it tight and diagnostic:

- **Each smell, named precisely** — Feature Envy, Divergent Change, Shotgun Surgery, Long Method, N+1, missing authorization, and so on. If you can't name it, describe the mechanism rather than reaching for a vague label.
- **Location** — `file:line` for every finding.
- **Severity** — how much this actually costs, so the orchestrator can rank across problem spaces.
- **Evidence** — the specific thing that makes it true (the second reason the class changes, the query inside the loop, the unscoped `params`).
- **The files most worth reading** — the handful the orchestrator needs in context to discuss your findings line by line.

Return findings only. Do not contact the user, and do not write review prose or recommendations — the orchestrator runs the session, reads the key files, and decides what to surface and when.
