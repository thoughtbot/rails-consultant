---
name: trace
description: Run a scenario and record what actually happened.
argument-hint: "[scenario, e.g. \"user creates an account\"]"
---

# Trace

Reading code tells you what *should* happen. Running it tells you what does: the
callback nobody mentioned, the job that enqueues two more, the email that goes out
twice. That's the gap this fills. The output is a record, in order, of what one
scenario did when it ran, with every step marked as seen or only read.

Two ways this fails. You read the code, write it up in the past tense, and it looks
exactly like a run — so the reader trusts a guess as much as an observation. Or you
run a step that can't be undone: a process gets killed, a database gets dropped. The
first is worse, because nothing about it looks wrong.

## 1. Pin the scenario

The scenario is `$ARGUMENTS`, or ask for one. It arrives as a sentence ("user creates
an account"), a route, a command, a job name.

Turn it into three things before running anything:

- **Entry point.** The route and handler, CLI command, or job that starts it — found
  in the code, not assumed. Two plausible ones (sign up by form, sign up by invite)?
  Take the common one, say which, and name the other as its own trace.
- **Starting state.** Who is acting and what exists already. "A signed-in user who
  owns one project with one app." Give every association the scenario reads or
  deletes at least one row. A delete run against a record with no children can't
  show you the child table it forgets to clean up.
- **Input.** The real params: `email: "sam@example.com"`, not "valid params".

Don't ask the user for these. Find them; say what you picked in one line.

## 2. Set up a development run

Run it in the **development environment**: the app's real configuration, the one a
developer sees. The test environment swaps things out — jobs run inline, mail and
broadcasts go to fakes, outside calls are stubbed by the test setup — so a trace
there records the test harness as much as the app. Development is made for this:
its data is disposable and its outside calls go to sandbox accounts.

Read `references/running.md` now. It has the recording taps and the setup details.

**Starting state.** Build it in the development database with the app's own models,
or its factories if development can load them. Create the actor fresh rather than
borrowing a row that's already there, so every id in the trace is one this run made.

**How to drive it.** In order of preference:

1. **A script that loads the app in development** and sends the request through it
   in the same process (the stack's in-process request helper, or call the handler
   directly). Same process means you can record outside calls and listen to the
   app's own events.
2. **The dev server on a spare port**, with a real request sent to it. Use this when
   the app can't be driven in-process. Stop it after.

Never production, never a staging database.

**Record every outside call.** HTTP calls, payment or email providers, LLM APIs:
let them go out, and log the URL and request body of each. Then read every
captured body, field by field, before writing up. What the app actually sends is
where bugs hide that no one reading the code sees: `"description": "#<Proc:0x...>"`,
`"name": "[object Object]"`, `undefined`, an empty prompt, a user's email in a
field meant for an id. Anything that isn't what the code plainly meant to send goes
in Surprises. Redact keys and tokens before writing a captured call anywhere.

**Stub anything destructive.** Killing processes, dropping databases, deleting or
moving files outside the repo. Intercept it in your script before the scenario
starts, record the call it *would* have made, and return what the real one would.
For files, point the run at a temp directory. Can't be intercepted safely? Don't
run past it. Stop the run there, and trace the rest by reading, marked as read.

Never run a destructive step for real to see what it does. A trace that says "would
have run `dropdb app_42`" is complete; one that ran it isn't a trace, it's an
incident.

**Follow the chain.** Jobs enqueued during the scenario are part of it. Run them the
way production does: after the request returns, not inside it. Queue them during
the request, then perform them yourself and keep recording, one level at a time,
until nothing new is enqueued or you hit a step you stubbed. Don't start the app's
real job worker: it would pick up jobs you didn't queue. Say which job backend the
app normally uses, and where you stopped and why.

## 3. Run it and leave nothing behind

Note `git status --porcelain` before. Put throwaway files where you'd delete them
anyway, run, capture the output, then clean up:

- Delete the throwaway files. `git status` after has to match before; if the run
  touched something you didn't write, say so.
- Stop any server or process you started.

If it fails to run — missing database, broken setup, a migration that won't apply,
a dependency that isn't installed — that's a result. Don't install or upgrade
packages to get past it: they land in directories other projects share. Work
around it inside your throwaway files if you can, and say what you did. Otherwise
report it, try the next route once, and if nothing runs, fall back to reading the
whole path and say plainly at the top that nothing was executed.

## 4. Write it up

Read `assets/trace-template.md` and fill it in. What makes a trace worth having:

**Every step is marked `ran` or `read`.** `ran` means you saw it in the recorded
output of this run. `read` means you got it from the code. `stubbed` means the code
reached it and you intercepted it. No step goes unmarked, and a step you saw only in
the code is never written up as though you watched it happen.

**Real values from the run.** `INSERT INTO users (email) VALUES ('sam@example.com')`,
`Project id=17 "Sam's project"`, `WelcomeEmailJob enqueued on default`. Not "a user
is created". The numbers in the drawing and the ledger come from the same run.

**Order is the point.** Draw it as a sequence, what happened then what, with
branches only where the run took one or a guard stopped it. Plain text, under about
seventy characters wide, labels from the codebase.

```
POST /users  email=sam@example.com
   |
   v
UsersController#create
   |-- INSERT users id=31
   |-- after create: provision_workspace
   |     |-- INSERT organizations id=9
   |     `-- INSERT projects id=17
   |-- enqueue WelcomeEmailJob
   v
302 -> /projects/17
```

**Surprises get their own list.** The things someone reading the code would miss: a
callback three files away, a query per row, a job that runs twice, a write inside a
GET. If there are none, say "none" rather than inventing one — that's also a finding.

**Holes get named.** What you stubbed, what you only read, where you stopped the
chain. Those are what the next person would have to check by hand.

Keep prose short. The ledger and the drawing carry it; prose explains the surprises.

## 5. Save and show it

Write the trace to `docs/traces/<slug>.md` at the repo root, a short kebab-case slug
(`user-creates-account`). Create the directory if needed. If the file exists, it's an
older trace of the same scenario: overwrite it, and say in one line what changed
since, if anything did — that diff is often the most useful thing in it.

Don't paste the trace into the chat. The file is the record; the chat is the
headline. Reply with the path and at most three bullets: what the scenario
did in one line, the biggest surprise, and anything stubbed or only read that
changes how far to trust it. If the run turned up nothing surprising, say so.
Don't end on an offer.

It's a record of what the code did on one run, not a spec and not a review. Don't
recommend changes in it. If the run turned up a real bug — a double charge, a write
that skips authorization — tell the user directly, outside the file, in one line.
