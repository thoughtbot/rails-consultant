---
name: slice
description: Cut a feature or idea down to one full-stack slice.
argument-hint: "[feature or idea to slice]"
---

# Full-stack slice SPEC

A full-stack slice cuts vertically through every layer a feature needs: storage, logic, interface, integration. It ships on its own, and a user gets something they couldn't get before. The opposite is a horizontal slice ("add the schema", "build the API", "design the UI"), which ships nothing anyone can use and hides the integration pain until the end.

Full stack means whatever this project's fullest stack is. For a web app, storage through to screen. For a CLI, argument parsing through to printed output. Let the repo tell you its layers instead of assuming.

The job is finding the version that costs a fraction of the work and is still worth shipping. The SPEC goes to a session that has none of this conversation, so it has to stand alone.

## Workflow

Arguments start with `--auto`? Nobody will answer. Read [Autonomous mode](#autonomous-mode) first; it replaces the interview and both gates below.

1. Capture the raw idea in the user's words.
2. Recon the codebase with subagents. Wait for them; the interview depends on what they find.
3. Run the interview to cut scope.
4. Fill in the SPEC template and paste the whole thing in a message for review. This is the skill's only approval gate.
5. Write the approved draft to `docs/specs/<slug>.md` and tell the user the path.

**The gate is the SPEC text, and it is the only gate.** Never end a turn with a prose recap of the slice and "confirm and I'll write the SPEC" — that asks the user to approve something they haven't read, which is the whole problem. If you're about to send that message, send the draft instead. And before writing the file, check one thing: the exact text you're about to write appeared in an earlier message and the user said yes to it. If it didn't, you're in step 4, not step 5.

### 1. Capture the raw idea

The feature, if the user passed one: `$ARGUMENTS`

If that's empty, ask what they're building. Don't tidy up the answer. The messy version carries the motivation you need for the job story.

### 2. Recon the codebase, before any questions

Finish this before you ask anything. An interview run blind produces cuts that sound reasonable and turn out wrong: you propose building something the app already has, or you cut something load-bearing because you didn't know what depended on it. In a mature codebase the best cut is usually "that already exists, reuse it", and questioning the user won't surface it. They usually don't know either.

Check how much codebase there is first (`git log --oneline | wc -l`, a source file count). A near-empty repo has nothing to find, so say that and go straight to the interview.

Otherwise tell the user you're reading the codebase first. Then launch subagents in parallel (`Explore`, or `general-purpose`), one per angle:

- **Closest prior art.** The existing feature most like this one, traced end to end. These are the files worth copying.
- **Territory.** Every layer this would touch, in whatever form the project has them. What's already there, what's missing.
- **Conventions.** How the codebase handles its inputs, its trust boundaries if it has any, and its tests.

Ask for exact file paths rather than prose, because you need that specificity to argue for cuts the user can verify. Have each name up to 10 files worth reading, fewer if fewer are worth it, then read those files yourself.

Keep the paths as you go. The SPEC carries a short list of them under `## Where to look`, because a path is cheap to check and expensive to find again. Only files you actually read qualify: a path a subagent mentioned and you never opened is a guess with a citation on it.

Then give the user 3 to 5 lines on what you found: what already exists, the closest pattern, what's missing. If recon misread the codebase, this is where they catch it, and that's far cheaper than finding out once the SPEC is written.

No repo, or no subagents available? Do a timeboxed grep and skim yourself, or say plainly that you're cutting scope without knowing what already exists, which is the weaker version of this.

### 3. The interview

If the idea already arrives slice-sized, say so and go straight to step 4. The rounds below are for ideas that need cutting.

Rounds of 2 to 4 questions. One at a time is a slog; twelve at once is a survey.

**Lead with a cut.** "Should we include search?" makes the user do the work, and they'll say yes. Instead: *"I'm cutting search. With a dozen records the user can scan the list. Push back if that's wrong."* A proposed cut is easy to accept and easy to reject, so it moves fast, and whatever they defend tells you what actually matters. Use `AskUserQuestion` when the choices are genuinely enumerable, plain questions otherwise.

**Defend the cuts you propose.** If they ask why, answer it rather than restating the cut. A cut you can't answer for wasn't grounded in the recon, so withdraw it.

**Spend the recon.** You did the reading so the cuts could be specific, so use it. *"I'm not building an exporter. The reports page already renders CSV at `<the file you found>`, and this can go through the same path"* is a cut the user can verify. Name the file. Vague cuts get argued about; grounded ones get accepted in one line.

**One test for everything.** For each behavior still standing: cut it, and does the slice still deliver the job story's outcome? If yes, cut it. Nothing earns an acceptance criterion until it has survived that question out loud. Guardrails are exempt.

**Know when you're at the floor.** Two rounds with no new cuts means you're there: removing one more thing would break the demo or leave the user with nothing new. Past that you're negotiating trivia, and the remaining scope is the user's to defend rather than yours to keep whittling. Say which cut you considered and rejected, and why. They can overrule you.

There is no checkpoint at the end of the interview. The moment you're at the floor, go on to step 4 in the same turn and draft the SPEC.

**Guardrails.** Four things survive however thin the slice gets: anything that risks data loss or corruption, authorization boundaries that would expose other people's data, whatever makes the slice demo-able, and tests for the acceptance criteria. Each becomes an acceptance criterion even though it would pass the cut test, which is why they're listed separately. Deferring one is a decision rather than a cut, so say it plainly and record it under `## Owed`. It isn't gone, it's owed.

**If it won't cut, change the axis.** A feature that resists slicing is usually being cut in the wrong direction. Cut by workflow step, by user, or by input, not by layer and not by a "phase one" that ships nothing. The tell is a slice nobody can exercise end to end without you narrating it for them. Change the axis instead of thinning it further. And if the user says the axis is wrong, that outranks every cut on the table: start the rounds over on their axis rather than defending the cuts you've already made. The recon still holds unless the new axis points somewhere it didn't reach. Second axis change, draft on the axis you have.

### 4. Show the SPEC before saving it

Read `assets/spec-template.md` now, before you write anything else. Reading it at save time instead is how this step turns into a freehand summary.

Fill it in, then paste the filled-in file into the message. Not a description of it, not the job story and a sentence about the slice: the file, every section, acceptance criteria included, worded the way it will be worded on disk. The wording of a criterion *is* the scope boundary, so the text under review has to be the real text. If your message has no acceptance criteria in it, you skipped this step.

The message looks like this, and nothing is on disk when you send it:

~~~
Here's the SPEC I'd save to `docs/specs/{slug}.md`. Nothing written yet.

```markdown
{the filled-in template, in full}
```

**What I cut:**
- {cut} — {they pushed back / passed without comment}
- ...

Say the word and I'll save it.
~~~

The template is thin on purpose: title, one-sentence summary, job story, acceptance criteria, plus `## Where to look` and `## Owed`, each only if it has something to carry. This is a contract rather than a design doc. Don't write a design, a file plan, or an ordering — that's the implementing session's to decide, and it'll have read the code more recently than you.

Two things do carry over. Decisions, because they go missing rather than stale: "go through the existing export path rather than building a new one" belongs in the summary sentence if the user approved it. And the paths from step 2, because a path is cheap to check and expensive to find again.

**`## Where to look` is a reading list, not a plan.** At most six paths, fewer if fewer earn it: the ones you'd open first if you were implementing this yourself. Each gets one line on why it matters to *this* slice — "the CSV rendering this can go through", not "the reports controller". A path with no reason is noise the next session has to open before it can judge it, which costs more than leaving it out. A path already named in the summary sentence or a criterion doesn't repeat here.

Spend one of the six on the test nearest this slice, and name the command that runs it. Reading the local test idiom is the one piece of exploration the implementing session is *required* to do before its first test, so it's the line that saves real work. Stamp the section with `git rev-parse --short HEAD`: the paths survive a moving repo better than the reasons beside them do, and the stamp is what lets the next session tell how much to trust each one.

**The acceptance criteria are the scope boundary.** There's no in/out list because there doesn't need to be one: if a behavior isn't in a criterion, it isn't in the slice. That only holds if the criteria are tight, so write them as behavior someone can observe by using the thing. Given a starting state, when the user does something, then something is observably true. "A blank title is rejected by the validation layer" names an implementation the next session should get to choose; "when I submit with the title empty, then I see the form again with an error on the title field" says the same thing and decides nothing. Outside a UI the same rule holds: "when I run `report --format=csv` with no matching records, then it prints the header row and exits 0". Where recon found something specific enough to change the work, put it in the criterion itself.

One criterion per observable behavior, usually three to six. One means you spec'd a fragment; ten means you didn't cut.

Replace every `{placeholder}`. Nothing in braces survives into the finished file, and a section with nothing to carry gets deleted rather than padded.

Mark which cuts they pushed back on and which passed without comment, because a silent round isn't agreement. The SPEC won't carry the cut list, so this message is the only place the user sees what's out while they can still object. Make it a real list rather than a summary.

Then stop. Don't write the file in the same turn as the playback, whatever their last message implied. Scope pushback sends you back to step 3. Wording pushback is cheaper: fix the draft and show it again in full, because a diff of a file they haven't seen on disk is harder to read than the file.

### 5. Write the file

Write to `docs/specs/<slug>.md` at the repo root (`git rev-parse --show-toplevel`), with a short kebab-case slug (`invoice-csv-export`, not `export-invoices-as-csv-file-v1`). Create the directory if it doesn't exist. If the file already exists, read it: same feature, ask whether to replace it or revise it in place; different feature, pick a different slug. Never auto-suffix, because `/multi-lens-review` finds SPECs by slug and can't tell two near-identical ones apart. Then tell the user the path.

Write the draft they approved, unchanged. Anything you improve between approval and write is unreviewed, and the point of step 4 was that the file matches what they signed off on. If you spot a problem, show the corrected draft and get the nod again.

If you can't point to the message where you showed them this text, don't write the file. Go do step 4.

## Autonomous mode

Only when the arguments start with `--auto`. The rest of the arguments are the idea, often a GitHub issue body. Nobody is there to answer: your final reply gets posted as a comment, a human may edit it there, and the next step picks it up from the comment. Without `--auto`, ignore this section.

What changes:

- **Recon as in step 2.** Skip the 3 to 5 line summary; nobody is there to catch a misread.
- **No interview.** Make the cuts yourself, by the same rules: the cut test, the guardrails, changing the axis. Everything you'd have proposed is now decided.
- **Draft, then have it reviewed.** Fill in the template, then launch one fresh subagent with the draft, this skill's path, and the paths you read. It never saw your reasoning, so it can't be talked into it. Ask it to check: the template's shape kept word for word (`When` / `I want to` / `So I can`, `Given` / `when` / `then`), since the next step parses it; one job story, criteria a user could observe, cuts grounded in files that exist, guardrails kept, no horizontal slice. Tell it to report only problems that change the scope or make a criterion uncheckable, and to skip wording and style. A reviewer asked for problems always finds some.
- **Revise once.** Fix what holds up, drop what doesn't. No second review.
- **Guess, and say so.** Anything only a human could answer, like who receives an email or which plan a limit applies to, gets your best guess, recorded under `## Assumptions`. A guess the reader can see costs one edit; a guess buried in a criterion ships.
- **No file.** Don't write `docs/specs/`. On a CI runner it's thrown away unless pushed, and the comment is the handoff.

The final reply is the comment, so it carries nothing else:

~~~
<!-- spec -->
{the filled-in template, in full}
<!-- /spec -->

**What I cut:**
- {cut} — {why, with the file that grounds it}

**What the review changed:**
- {finding} — {fixed / rejected, and why}

_Written by {model name} ({model ID}) with /slice --auto. No human has edited this yet._
~~~

No code block around the SPEC: GitHub would show it as raw text. Write the two marker lines exactly as shown, each on its own line. GitHub hides them, so the SPEC renders, and the next step finds the SPEC by them.

The last line says which model wrote the comment, so a reader can tell AI text from a human's. Take the name and exact ID from your system prompt, like `Claude Opus 5.5 (claude-opus-5-5)`. Don't know it? Write `Claude` alone; never guess a model. Keep it below `<!-- /spec -->`, so it never lands in the SPEC.

## Job story craft

The shape is in the template. There's no persona in a job story. "As a hiring manager" tells you nothing about when the need arises; the situation does that work.

- **Situation** is a concrete moment with a trigger. "When I'm closing out the month and my accountant asks for our invoice history", not "When I am a finance user."
- **Motivation** is the problem rather than your solution. "I want our invoices out of the app in one file", not "I want to click an Export button." If the UI shows up here, you've written the implementation into the story.
- **Outcome** is why it's worth anything. It should imply what gets worse if you don't build it.

One job story per slice. If yours needs an "and", you have two slices. Spec the first and tell the user what the second one is.

## Notes

- Resist appending sections. A design note or a roadmap is defensible on its own, and together they turn the contract back into the design doc this avoids. If something must survive, it belongs in an acceptance criterion, in `## Owed`, or in conversation. Never in `## Where to look`, which is paths and one line each, not a place to park a decision.
- If the feature is genuinely large, you're still speccing exactly one slice. Tell the user what the remaining slices look like, in order, but keep them out of the file.
