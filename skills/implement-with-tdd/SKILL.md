---
name: implement-with-tdd
description: Implement a SPEC, plan, or feature  outside-in, with TDD. 
argument-hint: "[path to a SPEC or plan, or a description of the change]"
---

# Implement with TDD

Work from the outside in and let each failure name the next move. Stop at
shameless green; a later step refactors.

The discipline exists because you're fluent enough to write plausible code for
almost anything, and plausible isn't correct. A failing test tells them apart.

## What you were handed

The thing to build: `$ARGUMENTS`

If that's empty, ask. If it's a path, read it.

Take the acceptance criteria as the scope. Those are behavior, and behavior is what
you can test. A suggested design, a test path, an ordering: that's a guess from a
session that never ran the suite. Yours will run it, so your evidence is better.
Where the repo contradicts the plan the repo is right — say so rather than diverge
quietly.

A `## Where to look` section is the exception to that distrust, not to the scope
rule. Those paths are where a prior session already found the relevant code, so they
save you the search and not the judgment: open them before you go looking for
anything else, and treat nothing on the list as work you owe. The criteria are still
the whole scope. If a path is gone or turns out to be irrelevant, skip it and say so
in the report — don't edit the SPEC.

The list names the commit it was written at. When that isn't `HEAD`, the paths
usually still hold and the reason beside each one may not, so read the file before
you act on its description.

## Before the first test

Learn the suite:

- The command for one test file, and the one for everything
- Which layers exist here (end-to-end, request or API, unit) — you can only start
  at the outermost layer the repo actually has
- The local idiom: factories or fixtures, helpers, naming

Read the two or three tests nearest your area and copy their style, even where
you'd write it differently. `references/test-style.md` covers how to write the
test itself and what belongs at each layer; read it before the first one.

If the suite can't be made to run using the repo's documented setup, stop and
report what's missing — a missing database or service isn't something to work
around. If there's no test framework at all, stop and ask which to use.

## Size the feature

Roughly 200 lines of implementation is the budget for one feature. Count every
line you typed into a file that ships — views, routes, config, locales, `end`s and
blank lines included. Free: tests and the factories or fixtures feeding them,
comments, and generated files you didn't edit — schema dumps, lockfiles,
snapshots, scaffolding output. A migration you generated is free; the body you
wrote inside it isn't. Tests stay free here even where your usual diff budget
counts them.

Count what you added, not net. Deleting doesn't buy room, and code you moved
unchanged is free. `git diff --stat` minus your test files is close enough; don't
script it.

Estimate now, with the neighboring code read. Per criterion, name the files you'd
touch and whether the layer already exists — several criteria each needing a new
object is the shape that blows the budget.

If the estimate is over, stop before the first test. Report the number, the
criteria carrying the weight, and the smaller first cut you'd take instead — the
one or two criteria that stand on their own. Then wait. What to drop is a scope
decision, and starting is a way of making it for them.

## The loop

One criterion at a time, and only one test you wrote red at once.

1. **Write the outermost test for the criterion.** Drive it the way a user reaches
   the behavior, and assert on what that user can see. It should fail on the thing
   you haven't built, not on a typo.
2. **Run it and read the failure.** Literally — not the failure you expected.
3. **Make the smallest change the failure asks for.** Not the change that finishes
   the feature. `references/failures.md` maps each kind of failure to its next
   move, including which ones send you down a layer and which don't.
4. **Run it again.** A new message means you moved. An unchanged message means you
   did something necessary but insufficient, or you guessed — say which, and drop
   the change if you can't name what it unblocks.
5. **Repeat until green**, then run the tests around what you touched. A failure
   in something you never touched may predate you — check it against a clean
   checkout before you spend the session on someone else's broken test. Check the
   count against the budget, then take the next criterion, and run everything once
   at the end.

Work through every criterion without checking in. Four things earn a stop: a
suite you can't run, the same failure surviving two different fixes, work that
reaches outside the process or handles a secret, and the budget running out. The
last two are project decisions, not implementation details.

A library you already have installed is still someone else's call. The decision
isn't the install line, it's where the URL or credential lives, what the code
does when the call fails, and how the suite stays runnable offline. Storing a
password is the same shape. Lay the options out and wait — raising one and
closing it in the same breath isn't a stop.

When the count crosses, finish the criterion you're on and stop there rather than
opening the next one — a half-built criterion is worse than a missing one. Report
the count, which criterion crossed, and what's left unbuilt.

## Shameless green

Reach green with explicit, duplicated, readable cases. Spell the value out. Copy
the neighboring case and change what differs. Write one branch per case the tests
name, and none for a case no test named, since that branch is a guess you'd have
to maintain. A passing test is the signal to stop writing code.

You're trading changeability for clarity, not clarity for speed. Duplication is
cheap to remove later; a wrong abstraction drawn from one example spreads into
every caller first. The duplication is also the evidence the refactor runs on —
it shows where the seam really is.

Fakes aren't shameless, they're false. A hardcoded return value that satisfies the
test is fine; an accessor standing in for a column that ought to exist, or a stub
where the real call belongs, makes the test lie about what works. If the criterion
needs schema, add the schema.

Duplication counts against the budget. If spelling the cases out is what blows it,
keep the duplication and stop at the boundary above: that means the feature is too
big for one slice, not that it needs an abstraction.

No comments apologizing for the shortcut, no TODO promising to fix it, no
half-built abstraction for later.

## When you're done

Report the criteria you covered, any you left unbuilt and why, the tests you added
and where, the suite result, and the lines you spent against the budget, including
whether your estimate held. Then name the ugliest thing you left standing, because
that's where the refactor starts. Leave everything uncommitted.

Bullets, not a narration of the loop. They can read the diff.
