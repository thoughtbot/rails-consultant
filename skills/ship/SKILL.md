---
name: ship
description: Implement, verify and review a feature based on its SPEC, then open a draft PR.
argument-hint: "[path to the SPEC /slice wrote]"
---

# Ship

`/slice` gives you a SPEC. This runs the rest of the chain against it:

```
Prepare  --> Implement --> Review --> Verify --> Open
  prep        tdd          5 lenses    real app   draft PR
  refactor                 + fix       + shots    + check
```

Nobody has to be watching. A person can run it, or something in the cloud can,
and either way the draft PR is what you come back to.

Each step runs in a context that never saw the one before it. That's the whole
point — a session that just wrote the code is the worst possible reviewer of it,
and a session that watched the review happen writes a description that defends
the review instead of the change.

## Run it

Hand `assets/workflow.js` to the Workflow tool, with the SPEC path as `args`:

```
Workflow({
  scriptPath: "<this skill's directory>/assets/workflow.js",
  args: { spec: "docs/specs/<the-slug>.md" }
})
```

If `scriptPath` is refused, read the file and pass its contents as `script`
instead. Don't rewrite it inline from memory.

No SPEC path? Ask for one. The script throws without it, and every step after
`Prepare` measures itself against those acceptance criteria — the chain has
nothing to aim at otherwise.

## When it returns

The return value is the whole report — nothing reaches the user on its own.
Give them a tl;dr: what happened and what needs them. The PR holds the rest.

Four lines, in this order, in plain words. One sentence each, under 25 words;
detail belongs in the PR. Never print the return value's field names.

```
Draft PR: https://github.com/acme/billing/pull/42
Built: invoices are due 30 days after issue, overdue the day after.
Checked: tests green. Called Invoice#overdue? on a sample invoice; got true.
Needs you: nobody ran the app. 2 screenshots in tmp/ship/, not on the PR.
```

- **Draft PR** — `prUrl`. None means it never opened: say so with
  `notOpenedReason`.
- **Built** — the SPEC's criteria that got built, one line. Add any in
  `criteriaUnbuilt` as "not built: …".
- **Checked** — `suiteGreen` first; false means the branch is red, whatever
  else the run says. Then how `verified` checked the criteria outside the
  tests, or that nobody did.
- **Needs you** — only what applies, comma-separated: a red suite, unbuilt
  criteria, `reviewLeft` findings, `lensesUnchecked`, an app nobody drove,
  `screenshots` to attach (local paths; nothing uploads them yet), and a
  description nobody checked (`checkChanges` is null). Nothing applies? "Needs
  you: nothing."

PR not opened? After the four lines, hand over `title`, `body`, `notes` (as
`path:line` bullets), each in its own fenced block under a bold
label (**Title**, **Body**, …), ready to paste. Copy each note's body
whole, down to the line naming the model that wrote it. Fence notes with
`~~~`, since a note's drawing has its own ```.

Then at most three items from `afterward` a reviewer should know before
merging: open questions first, then assumptions. Quote them, label each by
step. Don't add your own; you didn't do the work. If you dropped any, say how
many, so the user can ask. Nothing reported? Leave it out.

The PR gets line notes, never a summary comment. What's still owed goes in
"Needs you", to the user, not to reviewers.

A halted run returns `haltedAt` and `reason` instead. Lead with those and the
decision the user has to make to unblock it:

```
Stopped at Implement: criterion 2 calls Ledgerly's API with a key.
You decide: where the key lives, what happens when the call fails.
Committed so far: due dates (criterion 1), suite green.
```

Decisions can be a short bullet list. Skip a line per step; the step reports
stay with you, so hand them over when asked.

## Why the script does the fan-out

A subagent has no tool for spawning subagents. Nested delegation doesn't exist,
and `agentType: 'general-purpose'` doesn't buy it either — both were checked.

That matters because `/multi-lens-review` is five reviewers held apart on purpose. Hand the
whole skill to one agent and it plays all five, which is the failure the skill
names in its own opening: one reviewer asked all five questions spends its
attention on naming nits and never reaches "those five files are one domain
object in a trenchcoat." So the script spawns the five itself, each told to read
one `agents/*.md` fragment and nothing else. The prompts stay in the review
skill; the script only owns the dispatch.

`/preparatory-refactor` loses its recon fan-out the same way, and takes the
fallback its own SKILL.md already sanctions — a timeboxed skim. Weaker, and the
report says so rather than letting a skim read as a sweep.

## Where it deviates from the skills

Three places, each because nobody is watching the run:

- `/preparatory-refactor` identifies and refuses to edit. Kept — a second agent
  makes the move, so the one proposing it isn't the one defending it.
- `/implement-with-tdd` says leave everything uncommitted. Overridden; every step
  commits through `/commit`, because the next one diffs against what the last one
  left, and `Open` never saw the sessions that wrote the code. The commit
  messages are its only record of why. The SPEC and the run's own artifacts
  (screenshots, diffs, notes) never go in a commit, and `/pr --auto` opens the
  PR with them still untracked.
- `/pr --auto` checks its own description with a subagent. A workflow agent
  can't spawn one, so the script runs that check as its own agent, after the PR
  is open, and the check edits the PR in place.
- `/multi-lens-review` refuses to apply findings unasked. Overridden for what it files under
  Defects and Compatibility — the two that cost something the moment this ships,
  which is why its own synthesis sorts them first. Conventions, domains and
  fidelity are judgment calls, so they stay in the report for you.

The gate is the heading, not the score. Confidence would be the wrong axis: the
review skill sorts defects by consequence precisely because a confidence-95
off-by-one in a log line matters less than a confidence-82 unbounded delete.

## Where it stops

Every halt carries out every report the run produced, because a halt is where you
pick the work up by hand and those reports are all you get.

- **Prepare** — the refactor agent stopped, or left the suite red. A
  behavior-preserving move that breaks tests broke the one thing it promised.
- **Implement** — any of `/implement-with-tdd`'s own stops: budget overrun, a
  suite that won't run, a scope question. Those are yours to answer, and starting
  anyway is how a workflow decides one on your behalf and calls it progress.
- **Review** — no base branch resolved, an empty diff, or a diff past 1500 lines.
  All three would otherwise produce a clean-looking review of nothing: five agents
  handed an empty file go find something in the neighboring code, and five handed
  2000 lines review the front of it and say nothing about stopping.

A dead agent halts wherever it dies, and says so as a dead agent — not as a
finding about your repo.

## What stays outside

Everything before the SPEC — `/domain-model`, `/slice`, and the `/understand`,
`/eli5`, `/rubber-duck` passes you make over what they produce. Those are the
steps where you're the one doing the thinking, and handing them to a fleet of
agents defeats why you ran them.

`Verify` is the weak link in here. It screenshots what it can, but nothing
uploads them yet, since `gh` can't attach images to a PR. Treat its report as
"the app started and the criteria appear to hold," then look yourself.
