---
name: feature-dev
description: Use this skill when someone wants to build a brand-new feature in a Rails app — also called a ticket, story, or slice — and go through the whole process with you rather than just getting code written. The intent to match — they name something to build ("add X", "let users do Y", "develop Z") and want it done the disciplined, complete way — scoped into the smallest shippable slice, built test-first with strict TDD, then reviewed before merging. Any request that pairs building a feature with wanting it done thoroughly, "properly", "the right way", "from scratch", or "start to finish" — or that mentions defining the slice, writing tests first, or reviewing the diff — should trigger this. Do NOT use when there is no new feature to build end-to-end, such as reviewing an existing PR, adding tests to code already written, breaking an epic into stories, framework or version upgrades, performance tuning, or open-ended "how should I design or structure X" questions.
argument-hint: "[feature or slice to build]"
disable-model-invocation: true
---

# Feature Development

You are helping a developer take **one feature slice** from a rough idea to reviewed, shipped code. This is not autonomous coding — it's a guided workflow that borrows its backbone from systematic feature development but threads three disciplines through it: **slicing** to define the work, **TDD** to build it, and **code review** to close it out.

The workflow's whole reason for existing is to resist the pull toward premature code. Each phase earns the right to the next: you don't slice until you understand the feature, you don't build until the slice is sharp, and you don't consider it done until the diff has been reviewed. Hold that line — the value is in the sequence, not any single step.

**Scope discipline:** this workflow refines and builds exactly **one slice**. If the work is actually an epic — several independently shippable pieces — you'll surface that during framing and help the user pick the single slice to build now. Building more than one slice in a pass defeats the point; the payoff is a tight loop of shape → build → review on a small, real increment.

Use `TodoWrite` to track the phases so the user can see where they are.

---

## Phase 1: Frame the work

**Goal:** understand what the user wants to build, and confirm it's a single slice before investing in anything else.

Initial request: `$ARGUMENTS`

If the feature is unclear, ask what they're building — the problem it solves, who it's for, what "done" looks like. Keep it short; the `slice` skill will interrogate scope properly in Phase 3, so here you only need enough to explore the codebase intelligently.

Then make an explicit call on size. Ask yourself (and the user, if it's genuinely ambiguous): **is this one slice, or an epic hiding several?** A slice is something a real user can touch and a stakeholder can see value in, shippable on its own.

- **One slice** → confirm your understanding in a sentence or two and move to Phase 2.
- **An epic** → say so plainly. Help the user name the pieces briefly, then ask which single slice to build in this pass. Do not try to build them all. If they want the full epic broken down rigorously first, that's the `slice` skill's Path B on its own — point them there and stop.

---

## Phase 2: Explore the codebase

**Goal:** ground the slice in how this codebase actually works, so the acceptance criteria are realistic and the implementation follows existing conventions instead of inventing new ones.

This matters most in a mature Rails app: the right slice and the right tests depend on where similar features live, what the testing conventions are, and which abstractions already exist. Skipping this leads to slices that ignore reality and code that fights the grain of the app.

Match the effort to the feature. For a small, well-understood change, a few targeted reads inline are enough — don't spin up subagents to rediscover something you can see in one file. For anything touching unfamiliar territory or spanning layers, launch 2–3 general-purpose subagents in parallel (via the Task tool) as codebase explorers — give each the brief in `references/code-explorer.md` plus a different angle to cover:

- Find features similar to this one and trace their implementation end to end.
- Map the architecture and conventions for the area this slice touches (models, controllers, jobs, views, wherever it lands).
- Identify the testing patterns and factories relevant to this work — how do feature specs, request specs, and model specs look in this app?

Ask each explorer to return the 5–10 files most worth reading. When they return, **read those files yourself** before proceeding — the subagents build the map, but you need the detail in context to slice and test well.

Close the phase with a short summary of the patterns and conventions that will shape the slice: where the code will live, what it should look like, what to reuse.

---

## Phase 3: Shape the slice

**Goal:** turn the framed feature into one sharp, well-defined slice with real acceptance criteria.

**Invoke the `slice` skill** (Skill tool, `slice`) and let it run the conversation. Because Phase 1 already established this is a single slice, `slice` should sharpen it into one job story (its Path A) rather than break an epic apart. Feed it what you learned in Phases 1–2 so the conversation starts warm instead of from zero.

What you need out of this phase is the deliverable `slice` produces: a job story with a clear **"ships when"** and a concrete list of **acceptance criteria** — happy path, edge cases, and error states. Those acceptance criteria are not paperwork; they become the failing tests in Phase 4. Push (or let `slice` push) until each criterion is specific and verifiable — "a user can X and sees Y" — because a vague criterion produces a vague test that proves nothing.

Do not move on until the user is satisfied the slice is genuinely the smallest thing that delivers real value. If slicing reveals the work is bigger than one slice after all, return to the Phase 1 decision: pick one slice, defer the rest.

---

## Phase 4: Build it test-first

**Goal:** implement the slice with strict, outside-in TDD, driven by the acceptance criteria.

**Invoke the `test-driven-development` skill** (Skill tool, `test-driven-development`) and follow it without shortcuts. Hand it the slice's acceptance criteria as the specification: each criterion is a behavior that needs a failing test before any production code exists.

The two skills fit together naturally — `slice` produced the observable behaviors, and TDD drives them outside-in: start with a feature spec for the "ships when" behavior, let its failure push you down through request and model specs, and write minimal code at each layer. The acceptance criteria are your checklist; the slice is done when every one of them is covered by a test you watched fail and then pass, and the suite is green with pristine output.

Honor the Iron Law from that skill: no production code without a failing test first. If you catch yourself wanting to skip ahead "just this once," that's exactly the moment the discipline is paying off. When every acceptance criterion is green, the slice is built — move to review.

---

## Phase 5: Review the diff

**Goal:** catch the bugs, quality issues, and convention violations that TDD alone won't surface, then fix them before the slice is considered shippable.

TDD proves the slice does what the acceptance criteria demanded — it does not prove the code is simple, secure, or idiomatic. That's what this phase is for, and it runs against the **diff for this slice** (the changes since the branch point).

Run Claude Code's built-in code review over the slice and let it apply the fixes automatically:

```
/code-review high --fix
```

- The **level** sets how hard the review looks. `high` is the right default for a focused single-slice diff — drop to `medium` for a trivial change, or raise to `xhigh`/`max` for security-sensitive or subtle logic where a missed issue is expensive.
- **`--fix`** applies the fixes for confirmed findings directly instead of only reporting them, which is what we want here — the slice should come out of this phase already corrected. (Use **`--comment`** instead when the intent is to surface findings without changing the code — e.g. the user asked for a review but wants to decide on the fixes themselves.)

The built-in review already filters to high-confidence findings and verifies them before it acts, so there's no separate confidence pass to run. `references/code-review.md` documents the standard it applies — the ≥ 80 confidence bar, the Critical vs. Important severity split, and what counts as a false positive — if you want to understand what it's weighting or need to fall back to a manual review when the command isn't available.

Because `--fix` edits code outside the red-green-refactor loop, **re-run the full suite once it finishes** to confirm the slice is still green and nothing regressed:

```bash
bundle exec rspec
```

If a fix changed behavior that isn't yet covered by a test, add the missing test — failing first, per Phase 4 — so the correction is locked in and can't silently regress later. Then briefly summarize what the review changed: what it fixed, anything it flagged but deliberately left, and confirmation the suite is green.

---

## Phase 6: Summary

**Goal:** close the loop.

Mark the todos complete and give a short summary:

- **What shipped** — the slice, in one line the user could paste into a PR description.
- **Acceptance criteria** — confirm each is met and tested.
- **Key decisions** — anything notable from slicing, testing, or review.
- **Files changed** — the diff at a glance.
- **Next steps** — if this was one slice of a larger epic, name the slices still waiting.

---

## Notes on the disciplines

The pieces this workflow orchestrates are each rigorous on their own; your job is to run them in sequence and keep the handoffs clean, not to water them down.

- `slice` is Socratic — it leads the user to define the work through questions. Let it. Don't pre-answer for them.
- `test-driven-development` is strict about order. Don't let the momentum of a clear slice tempt you into writing code before the test.
- The built-in `/code-review --fix` does the reviewing and fixing; your responsibility after it runs is to make sure the suite is still green and that any behavior it changed is covered by a test. A green suite is the signal the slice is actually shippable, not just that the review finished.

If any of the three skills isn't available in the environment, follow its `SKILL.md` directly (in `skills/<name>/SKILL.md`) rather than skipping the phase — the sequence is the point.
