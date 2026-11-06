---
name: eli5
description: Explain something to someone who knows nothing about it.
argument-hint: "[code, tool, process, or concept you have no familiarity with.]"
---

# ELI5

The user has no foothold. `/understand` questions them about a model they already
hold; here there is no model to question, and asking produces a guess you then have to
correct. So read the thing, then explain it — plainly, concretely, once.

Two ways this fails. You explain it in the vocabulary of the thing itself ("the
reconciler converges the cluster toward desired state"), which only reads to someone
who already understands it. Or you reach for concreteness and invent it: a config
value that isn't in the file, a sample record nobody has. The invented one is worse,
because it's memorable, wrong, and this reader has nothing to catch it with.

## 1. Find the thing

The target is `$ARGUMENTS`, or ask. It arrives as a path, a name they keep seeing
(`sidekiq`, `helm`, `useEffect`), a word off a ticket (`chargeback`, `dunning`), a
link, or pasted text.

A path is the thing. A name or a word gets looked for in this repo first — manifests,
config, `grep -ri` — since the version this codebase uses beats the general one, which
covers ten features they'll never touch. Not here at all? Say so in one line, explain
it in general, and skip the trace agent below; there's nothing for it to read.

A directory: pick its entry point and say that's what you took. Don't ask what they
already know or what they mean to do with it — questions are what they came here to be
spared.

## 2. Send agents to read it

Launch subagents in parallel (`Explore`, or `general-purpose`) and wait. Three angles,
one agent each:

- **What it's for.** What job this does for a person, who that person is, and what
  visibly breaks if it vanishes. Tell the agent to answer without using the thing's own
  vocabulary, or it hands back the README's first paragraph.
- **One real trace.** A single instance start to finish, in order, with the branch at
  each step and what happens when it fails — real route, real config value, a row from
  seeds or fixtures, a real filename, cited `file:line`. This is what step 4 draws.
- **The words.** Every term a newcomer would bounce off, and what each means *in this
  repo*, which is usually narrower than in general.

Tell each that "I couldn't find a real example" is an acceptable answer, or an agent
with no way to come back empty manufactures one that reads exactly like a real one. If
the trace does come back empty, say so in the explanation — a gap you name costs less
than a plausible value you filled it with.

Then open the files behind the claims you're about to assert, because a citation you
took on trust is how you confidently explain a function that doesn't exist. If you had
to skim, name what you couldn't verify — that's theirs to know. How the answer got made
isn't, at either end of it.

## 3. Explain it

**Lead with the job.** "This decides who gets charged and when," before any mechanism.
Mechanism has nowhere to attach yet.

**Then a simple analogy,** right after the job: one comparison from everyday life that
a kid would follow. Keep both free of file, class and code names — even the file they
asked about — since a path is jargon to this reader until the analogy has given it
somewhere to land. A job queue is the ticket rail in a restaurant kitchen — the waiter
clips the order up and walks away, and a cook pulls it down when free. Map its pieces
onto the real ones and carry it through the drawing's values, then say where it breaks
if the gap will bite them. One analogy, not a string of them. If they ask for no
analogies, or for a different framing, do what they asked.

**Anchor the mechanism to something they already have:** elsewhere in this same repo,
then the stack they already work in (`CLAUDE.md` and the rest of the repo say which).
The second rung is the one that gets skipped — "this file is that stack's router" lands
where first principles don't.

**Say the plain version first and the real name once, after,** so they can go search
for it: "the server kills the process when the machine runs low on memory; the logs
call that *evicted*."

**Show real values.** `ORDERS_PER_PAGE = 25`, so page 3 starts at order 51.

**Draw it** — step 4. Not optional.

**Stop at roughly thirty lines of prose** plus the drawings. Past that you've started
teaching the subsystem, and completeness is what loses this reader. The bar is that
they could describe the thing to a coworker in two sentences.

**Name the holes** — what recon couldn't reach, what the code doesn't answer. A hole
you name is one they can go ask a person about.

**Last pass before you send,** and it's the one that matters most: reread hunting for
words that only land for someone who already knows this thing. Gloss each in place or
cut it. Read the labels inside your drawings too — a term in the picture is the one
they can't skip past, and it's where this pass usually misses. "Basically", "simply",
"just" and "under the hood" mark a sentence you didn't finish writing — finish it.
Don't end on an offer of further services.

## 4. Draw it

At least one drawing, every time. Plain text, in the chat, built from the trace agent's
values. If you can't find a shape worth drawing, you don't understand it yet — go back
to the trace rather than writing another paragraph.

**Order — what happens, then what.** Draw the failure branches; a happy path alone is
the version that leaves them stuck at 2am. Elapsed time goes on the arrows, never on a
scale, which would lie about the spacing.

```
POST /webhooks/stripe
      |
      v
  verify signature --- bad --> 400, nothing else runs
      |
     good
      v
  enqueue ChargeSucceeded --3s--> worker marks invoice #4821 paid
```

**Boundary — where each part runs, and what crosses.** For anyone meeting an
unfamiliar stack this is usually the drawing that unlocks it.

```
   browser                |  server
  -------------------------+---------------------------
   app/page.tsx renders    |  auth.ts holds the secret
   click "Sign in" ------- | ---> POST /api/auth/signin
                           |  sends back: a cookie, no token
```

**Change — what goes in, what comes out.** Two columns of real values beat any sentence
describing the transformation.

```
"123 Main St."      -->   "123 main st"
"123 main street"   -->   "123 main st"
```

**Structure — which nouns exist and how they hang together.** This is the shape for
explaining a domain, where there's no sequence to follow.

```
Subscriber --- has many ---> Invoice --- has one ---> Charge
                              |
                              +-- unpaid 30 days --> "in dunning"
```

**Containment — what wraps what.** Nested boxes, the one that stops a stack of wrappers
being magic.

```
+-- your call to getActivities() -----------------+
|  +-- retry wrapper, 3 attempts ---------------+ |
|  |  +-- fetch() to strava.com/api/v3 -------+ | |
```

**Choices — how similar things differ.** A table, with the columns that actually differ
and nothing else.

Four rules hold these up:

- **Real labels from their repo.** "Service A" and "Service B" draw the category, not
  their system — the same picture would be true of any app.
- **Same values as the prose.** Numbers in the drawing and numbers in the text come
  from the one trace. Two versions of the same number is worse than neither.
- **One idea per drawing.** A legend means it's two drawings. Keep anything you drew by
  hand under about seventy characters wide, since a wrapped diagram in a terminal is
  noise; a table wraps on its own and is measured in columns instead — three or four.
- **One line under it naming the surprising part** — "nothing after the signature check
  runs." Never restate what the picture already said.

## 5. After

Answer follow-ups straight, and go read if you don't know. Never bluff here; everywhere
else the user catches a wrong answer, and this one can't.

Want it deeper on one piece? That's another pass of this skill on a smaller target, not
a licence to switch into the vocabulary you spent step 3 avoiding. Don't quiz them —
being tested is `/understand`, and it's worth mentioning only if they ask what's next.
