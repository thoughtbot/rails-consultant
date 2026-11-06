---
name: domain-model
description: Turn a described business process into a domain model.
argument-hint: "[business process, or a path to a description of one]"
---

# Domain model

The user describes how their business actually works. You come back with the concepts hiding in that description — and every one of them traces to something they said. An invented model is worse than none: it's fluent, confident, wrong, and in six months it's in the code under a name nobody in the business recognizes.

Five things come out, and nothing else:

| | |
| --- | --- |
| **Language** | The words the business uses, meaning what the business means. |
| **Flow** | The events, in order. Past tense — something became true. |
| **Rules** | Whenever X happens, we do Y. The branches and the exceptions. |
| **Aggregates** | Whatever protects a rule and emits those events. |
| **Contexts** | Where a word stops meaning one thing and starts meaning another. |

No entities-versus-value-objects, no repositories, no schema, no class diagram — those are implementation, and this is what implementation gets checked against. Don't read code either. The code already chose names, and the ones it chose are the loudest thing in the room; read them and they end up in the model, at which point the model can only tell you what the code already says.

## Workflow

1. Capture the process in the user's words.
2. Harvest the language before interpreting any of it.
3. Interview in rounds, leading with a proposed model.
4. Fill in the template and paste it whole for review — the only gate, and nothing reaches disk the user hasn't read in a message first.
5. Write to `docs/domains/<slug>.md` and tell the user the path.

### 1. Capture the process

The process, if the user passed one: `$ARGUMENTS`

That may be prose or a path — a transcript, a ticket, meeting notes. Read the file if it's a path. If it's empty, ask them to walk you through how the process works today, including the parts done by hand and the exceptions, because the exceptions are where the domain lives.

Keep their exact words. A description you tidied up is one you've already started interpreting.

### 2. Harvest the language

Pull out every noun and verb they used for something in their business, verbatim, before you model anything. If they said "lapse", the model says lapse — not expire, not deactivate. You're recording the language, not improving it; swap in a word you find clearer and the model stops being checkable by the person who described the process.

Two things here are findings rather than housekeeping:

- **Two words, one meaning.** "Cancel" in one sentence, "void" in another. Don't quietly pick one — sometimes it's sloppiness, sometimes they're two acts with two different consequences, and you can't tell from outside.
- **One word, two meanings.** "Customer" for the person who pays and the person who calls support. That isn't a glossary problem, it's the strongest evidence you'll get for a context boundary — evidence, not the boundary itself.

Play the harvest back as a plain list before interviewing. It's where they catch you having misheard a term, which is far cheaper than catching it in a finished model.

### 3. The interview

Rounds of 2 to 4 questions. One at a time is a slog; twelve at once is a survey.

**Define the word the first time you use it.** Aggregate, context, event — the user described a business, so this vocabulary is yours, not theirs. One line, in their own process's terms, before you ask them anything with it in: *"an aggregate is whatever gets to refuse — the thing that would stop you double-booking that table."* Three rounds of answers from someone who didn't know what you were asking are three rounds you have to throw away.

**Lead with a proposed model, not a question.** "What are the aggregates here?" hands the work back and gets you a shrug. Instead: *"I'm treating `Policy` as the thing that says no — it decides whether a claim is covered, and nothing else has enough information to. Push back if something else owns that."* A proposal is easy to accept and easy to reject, so it moves fast, and what they defend tells you what's real. If they ask why you drew a boundary there and your answer is a DDD principle rather than something they told you, you invented it — drop it and say so. A proposal they skip is not a yes; carry it to the playback.

**Never name a concept they didn't.** If the model needs a term the user never used, it's a proposal and gets marked as one: *"you don't have a word for the period between lapse and cancellation — I'm calling it the grace period, tell me what the business calls it."* Untagged invented vocabulary is how a model becomes unfalsifiable. Asking "what do you call this?" produces a word; it doesn't prove one was in use. Mark those the same way, and ask where they'd hear it said.

**Events** are past tense and business-observable: *Order placed. Policy lapsed.* The test is whether someone would say it happened without knowing there's software involved — "user clicks submit" is UI, "record saved" is storage. Order them; the sequence encodes which steps can't be reordered.

**Rules** are the conditionals, and they aren't events. *"Whenever the track is closed, we move to the bikepath."* Every "if", "unless", "sometimes" and "except when" in their description is one, and they're the reason step 1 asks for the exceptions. A flow with the branches stripped out is a happy path, which is the one version of a process nobody needed written down.

**Aggregates** answer *who says no?* Ask what rule must never break, then what the smallest set of things is that changes together to enforce it. If enforcing it needs two things to agree, ask whose job it is to make them agree: if it's the person doing the thing, they're one aggregate; if it's someone else's job or a nightly check, the rule holds but late, and it goes in `## Rules` with the delay the business will tolerate. An aggregate protecting no rule is a table — say so. And if nothing anywhere protects a rule, say that plainly too: it means the flow and its rules are the whole model, and either that's fine or there's a floor the business wants and hasn't got. Don't call it CRUD; that's a design instruction and you haven't earned it.

**Contexts** announce themselves when the user qualifies a term mid-sentence: *"well, a customer in billing is..."* Follow that hesitation. Other tells: different people, different teams, delays nobody minds. Before splitting, check the far side is a whole model rather than a mode — its own terms, its own flow, and someone who never has to care about the other. If one person walks through both in a single pass, it's a branch: put it in `## Rules` and keep one context. One context is a legitimate answer, but say why you're not splitting rather than just not mentioning it.

**Stop** when every event has an aggregate that emits it or is accounted for by a rule, every aggregate protects a rule you can state in one sentence, no term has two live meanings, and no two terms share one meaning without a ruling — either they're one act and the business names the survivor, or they're two acts and the Language table says what the difference is. Whatever still fails after three rounds goes in `## Unresolved` and you draft; an open question recorded in the model beats an answer you talked them into at question fifteen. No checkpoint here; go straight to step 4 in the same turn.

### 4. Show the model before saving it

Read `assets/domain-template.md` now. Reading it at save time is how this turns into a freehand summary. Fill it in and paste the filled-in file — the file, every section, not a description of it:

~~~
Here's the model I'd save to `docs/domains/{slug}.md`. Nothing written yet.

```markdown
{the filled-in template, in full}
```

**Terms I introduced, or that you only named because I asked:** {list, or "none"}

**Proposals you didn't answer, which I kept:** {list, or "none"}

Say the word and I'll save it.
~~~

Both lines print even when empty. The first catches the failure this skill exists to prevent; the second is the only place a silent round becomes visible, and silence isn't agreement. Replace every `{placeholder}`; nothing in braces survives to disk.

Then stop, whatever their last message implied. A correction to a boundary or an aggregate sends you back to step 3; a correction to wording is cheaper — fix the draft and show it whole again. Second time back, run one round rather than three, then draft what you have and put the disagreement in `## Unresolved`.

### 5. Write the file

Write to `docs/domains/<slug>.md` at the repo root (`git rev-parse --show-toplevel`), kebab-case and named for the process (`claims-intake`, not `how-claims-work-v2`). If the file exists, read it: same process, ask whether to replace or revise; different process, pick another slug. Write the draft they approved, unchanged — anything improved after approval is unreviewed.

## Notes

- The model describes a business, so keep what to build next out of it — a backlog, a roadmap, an ordering of work, each defensible alone and together the design doc this isn't. And expect it to rot, because nothing recompiles when it drifts: a short model that's right beats a thorough one nobody trusts.
