---
name: commit
description: Commit the current changes as atomic commits, recording risks, tradeoffs, and alternatives considered.
argument-hint: "[optional context to fold into the messages]"
---

# Commit

The history is the audit log for what an agent did. Months from now someone runs
`git blame` on a line nobody remembers writing, and the commit message is the only
record of why it's there. Inside `/ship` it matters sooner: the `/diff-explainer`
step never saw the session that wrote the code. It gets the SPEC, the step reports,
and these commits, and it won't annotate a decision nobody wrote down.

So a message's job is what `/diff-explainer` does for a whole branch, for one
commit: the why, the risks, the tradeoffs, and what got tried and thrown away. The
diff already shows what changed.

An argument is context ("addressing review feedback", "the migration is risky"),
never the literal message. Don't stop to ask for approval. Being asked to commit
means make the call, then report it.

## 1. See what's there

```bash
git status --porcelain -uall
git diff
git diff --staged
git log --oneline -15
```

Nothing to commit? Say so and stop. Never make an empty commit.

## 2. Commit only what you made

The tree can hold more than your work: a file the user was editing, a scratch
script, a `.env` with credentials, a log someone forgot. Commit what this session
produced. Leave the rest alone and name it in your report, so it doesn't look
like an oversight.

Can't tell if a change is yours? It isn't. Leaving it out costs a follow-up
commit. Putting it in ships someone else's half-finished work under your name.
Never commit anything that looks like a secret, even if you made it.

## 3. Group into atomic commits

One commit is one change that stands on its own. The test: if someone reverted
this commit alone, would what's left still make sense and still pass? Pass means
it's atomic. Fail means it's split too fine or bundled with something unrelated.

- A feature is one commit even across ten files. Model, migration, controller,
  view, and tests together. Splitting them gives commits that are each broken.
- Tests go with the code they test, not in a commit of their own.
- A refactor that makes room for the feature is its own commit, first. It changes
  no behavior, so a reviewer can trust it on a green suite and read the feature
  commit without the noise.
- A bug fix found along the way is its own commit, even inside the same file.
- A dependency bump the feature needed is usually its own commit.

When unsure, fewer commits. Over-split history reads worse than cohesive history.

## 4. Stage exactly the group

Whole files: `git add <paths>`. Never `git add .` or `git add -A`, which sweeps in
everything step 2 left out.

One file holding two groups: stage only the hunks for this one. `git add -p` needs
a terminal you don't have, so write those hunks to a patch and
`git apply --cached <patch>`. Check `git diff --staged` before every commit, since
a wrong patch fails quietly into a commit of the wrong lines.

Hooks run. If one fails or rewrites files, surface what it said, don't route
around it. No `--no-verify`, no amending, no pushing. This skill only adds new
commits on top.

## 5. Write the message

**Subject:** imperative, capitalized, no period, around 50 characters. Code
identifiers in backticks. "Cache `Mitie::NER` behind a mutex", not "Updated
caching".

**Body:** blank line, then prose wrapped at 72. Open with why: the problem, or
what this makes possible. Then whichever of these the session actually turned up.
Most commits have one or two. None is fine.

- **Tried and dropped.** "Memoizing without a lock failed during asset
  precompile, because the model file doesn't exist yet." This saves the next
  person from suggesting it.
- **Risks.** Deploy ordering, a migration that locks a big table, a new hard
  dependency, what happens at 10x the data, anything that fails silently.
- **Tradeoffs.** What got worse so something else got better, and why that
  trade.
- **Left out on purpose.** What this doesn't handle yet, stated as a fact.
- **Not checked.** Suite not run, suite red, a path only tested by hand, a
  service stubbed that behaves differently for real. An audit log that rounds
  "didn't run it" up to silence is worse than none.

Write these for a teammate skimming `git log`, not for the code. Plain words, no
"this ensures", "robust", "it's worth noting". Don't list the files you touched.
Bullets are fine when there are three separate risks. Otherwise prose.

**Never invent a why.** The good reasons come from this session: what you tried,
what broke, what surprised you. None of that is in the diff. If you're committing
work you didn't watch get made and nothing records why, write what the change
does and stop. A plausible reason that's wrong is worse than none, because the
next reader trusts it. If the user or the task gave you a reason, use it.

**Trivial changes** (typo, version bump, formatting) get a subject and no body.

End every message with the co-author trailer this session normally appends,
naming the model you're actually running, after a blank line.

### Example

```
Charge the card before creating the `Order`

Creating the order first left orphans whenever Stripe declined, and
the cleanup job that deleted them raced customers retrying checkout.

We tried wrapping both in a transaction, but a transaction can't roll
back a charge that already went through. Charging first means a crash
between the charge and the insert leaves a paid charge with no order.
That's rarer and visible in Stripe, so we traded one bug for a
smaller one. `ReconcileChargesJob` catching it is not built yet.

Checkout specs pass against the Stripe test double. Real declines and
network timeouts were not exercised.

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 6. Report

Show `git log --oneline` for the new commits. Then one line each for anything
worth knowing: a split you made, files you left uncommitted and why, a hook that
complained.
