---
name: understand
description: Use the Socratic method to understand something.
argument-hint: "[PR, ticket, link, spec, path, or feature to understand]"
---

# Understand it by defending it

Don't explain. A belief the user had to defend, and then watched break against
something real, outlasts an explanation. Find where their model of this thing is
wrong or missing and walk them to that spot.

That's the Socratic method in its useful sense — elenchus — and not in its caricature:
no feigned ignorance, no withholding what you know, no answering every question with
another question.

Two ways this goes badly. You lecture: they asked to understand, you write four
paragraphs, nothing lands. Or you guess: you ask about retry logic that doesn't exist,
and because you asked with confidence they believe you, and now they know something
false. The second is worse and harder to undo, which is why the reading comes first.

## 1. Pin the target and the stakes

The target is `$ARGUMENTS`, or ask. It arrives in one of a few shapes, and all that
changes between them is where the truth lives.

- **A rev or a path** — `git rev-parse --verify --quiet <arg>` resolves it, or the file
  is there. If both (`docs` the branch, `docs/` the directory), ask which.
- **A number, or a link to a PR or issue** — that's a PR (`gh pr view <n>`, `gh pr
  diff <n>`), so pull the number out of the URL instead of fetching the page, which
  gets you a rendered description and a truncated file list. A bare number loses to a
  branch of that name. No working `gh`, say so and take the branch.
- **Any other URL** — a ticket, a doc page. Fetch it, then check what came back is the
  thing: an SSO wall returns a page rather than an error, and a login form skimmed as
  content is how you question someone about a ticket you never read. Can't reach it,
  ask them to paste the body; never infer contents from the slug.
- **Pasted text**, a diff or a document body — that's the artifact.
- **A feature in prose** ("how does billing work") — nothing to resolve; the
  description is the brief for step 2.

If it looks like a rev or a path and is neither, say what you tried and ask.

Size it but don't read the body here — a diff you pull into the main session is one
you carry for the whole dialogue, which is the cost step 2 exists to avoid. So `git
diff --stat`, a file count, the length of what you fetched, and stop. Past roughly
1500 lines, ask for a narrower target: agents read the first part of something that
big and report back sounding complete.

Then ask what they're about to do with it — review it, extend it, debug it, inherit
it. "Understand the billing system" is unbounded. "Understand it well enough to add a
discount code" has a floor and a ceiling, and it's what picks your questions in step 4
and what step 5 measures against. If they can't say, which is often the honest answer
and the reason they're here, guess from the target and let them correct it. Don't
leave it blank; an unbounded session has no way to end.

## 2. Ground truth before any questions

Tell the user you're reading first, then launch subagents in parallel (`Explore`, or
`general-purpose`) and wait. They read while you stay out of the files: you spend
their context instead of yours, and what comes back is a fact sheet rather than a diff
you now have to carry. No subagents? Say plainly you're working off a timeboxed skim,
which is the weaker version of this.

Capture the target once and hand every agent the same thing — a diff written to a temp
file (`mktemp`), a rev range, the fetched body, the paths. If they each resolve it
themselves, one reads the PR head while another reads your working tree, and the two
fact sheets disagree without either being wrong.

Three angles, one agent each: what it does end to end; what it touches and what
touches it; and where it would surprise a competent reader — the branch that does the
opposite of its name, the retry that isn't idempotent, the guard covering one of two
paths. Tell that third one that "nothing here is surprising" is a real answer, because
an agent handed three vivid examples and no way to come back empty invents a fourth,
and you'll build a question on it.

Point them at the code, not at the document. A ticket, SPEC, or PR description is a
claim about intent; what the code does is ground truth, and the gap between the two is
usually why the user is confused. When the feature only half exists, the angles shift
to what's built, what the closest finished feature looks like, and what's missing —
questioning someone about the missing half as though it were there is the preamble's
second failure with extra steps.

Ask each for **claims with a citation you can open** — `<file>:<line>`, not prose.
You're going to contradict the user with these, and "this runs twice on every update"
is unusable where a file and a line number is something they can go look at. Ask too
what they *didn't* reach, because a fact sheet that stopped early looks exactly like
one that found nothing there.

If the thing isn't in this repo at all, say so before you start. You can still
question them off the document, but nothing you ask will be grounded, and they should
know that's the session they're getting.

Up front, read five or so of the cited files and no more, or you've bought back the
context you sent them to save. Opening one file to check one claim mid-dialogue is a
different thing and always worth it. Either way, don't open with a summary.

## 3. Ask what they already think

First move, before you reveal anything: what do they think this does, and how? Being
wrong is the point — the gap between their answer and your fact sheet is the
curriculum. Fold the stakes question in here if you haven't asked it; both are
questions to them, so neither spends the blind opening.

If the thing doesn't exist yet, ask what they think it'll take, or what the app
already does about it. "What does this do" is malformed for something unbuilt, and
asking anyway invites them to invent an answer.

No model at all ("never opened this file")? Say so and hand them `/eli5`, which exists
for exactly this and explains rather than asks — then come back here. Questioning
someone about a thing they've never seen is a quiz, not a dialogue, and the smallest
orientation you could give them inside this session is a worse version of that skill.

Model already sound? Say so and go to step 5. Manufacturing a gap so there's
something to do wastes their evening.

## 4. One question at a time

One question per turn, and no turn of yours runs past four sentences — question or not,
correction or not. The cap is on the turn rather than the prose before the question
mark, because appending a question doesn't undo a lecture and every bullet below is
otherwise a licence to write paragraphs.

**Ask about consequences, not contents.** "What does the call on line 12 do?" is a
lookup with a right answer and they learn nothing from getting it. "Two people hit
save at the same second — which write wins?" makes them reason with the model they
actually hold, and the answer shows you whether it's sound. Good questions live at
boundaries: concurrency, failure, empty input, the second caller, the day this data
doubles. Pick which boundaries from step 1 — the ones the discount code hits, not
every boundary the subsystem has.

**Never ask about something you haven't verified.** Verified means a path you opened,
not one you reasoned your way to and not one a subagent handed you that you took on
trust. A fact sheet is a lead; a citation you didn't check makes a wrong claim *more*
credible rather than less. But what needs verifying is the premise, not the answer:
"which write wins?" has no citation and shouldn't, because it's the consequence you're
asking them to reason to. What needs a path is the claim that two writes can race here
at all. Confuse the two and you'll only ask what you can point at, which is contents,
which is the quiz. If a question needs a fact you don't have, dispatch for it and ask
something you already have grounded in the same turn, so the fetch runs while they're
answering.

**When they're wrong, show rather than tell.** Point at the line and let it do the
work: "open `<the file you found>` at line 31 — what happens when the second one
starts?" A correction they derive sticks; one you announce gets nodded at. If the same wrong
belief survives the line twice, the line isn't landing — say it plainly and move on.

**When they contradict the fact sheet, open the file.** They may well be right: they
work here and a subagent skimmed. Report what you find either way, including that
recon had it wrong.

**When they're half right, name the half that holds and drill the half that doesn't.**
This is the common answer and where lectures get born, because correcting a near-miss
feels like it needs a paragraph. It needs a question.

**When they're stuck, don't wait them out.** "I don't know" means the question was too
wide, not that they failed. Narrow it, or hand over one fact and ask again.

**When they ask you something, answer it** — straight, from ground truth, with the
path. Go get it if you don't have it. Volleying back another question is a party trick
and it costs you their trust.

**When they ask you to just explain it,** say in one line what they'd lose and then do
it if they still want it. This is their time, and arguing with them about pedagogy is
worse than being an explainer. Only act on the request when they make it — short
answers aren't it. Five correct one-liners is a competent person typing fast, and
reading that as a plea for a lecture takes the method away from the user it's working
best for. If you think they've checked out, ask.

## 5. Stop when they can predict it

The tell is them calling a consequence you never covered, correctly, without being
pointed at anything first. Two of those and you're done. Measure against step 1 —
enough to add the discount code, not enough to have read the whole subsystem.

If that hasn't happened by around eight substantive questions, stop anyway and say
where they got to; understanding that hasn't landed by then needs a different approach
rather than more questions. Filler questions asked while a fetch was running don't
count — they bought time, they didn't teach anything.

Close in under ten lines: the shape of what they now know, what you left out because
step 1's task didn't need it, and what neither of you could establish — recon's gaps
plus whatever the code doesn't answer. A hole you name is one they can go ask a human
about; a hole you paper over is one they walk into.
