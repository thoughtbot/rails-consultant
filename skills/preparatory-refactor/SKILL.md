---
name: preparatory-refactor
description: Identify opportunities to introduce a refactor that would make a feature easy to implement.
argument-hint: "[feature description or path to a SPEC]"
---

# Preparatory refactoring

> Make the change easy, then make the easy change. — Kent Beck

You're looking for the refactorings *this* feature asks for. A preparatory refactoring earns its place by making the feature's diff smaller and more obvious, so if you can't show that, leave it out — a finding that stands on its own without the feature is a code review finding, and `/multi-lens-review` is where it goes.

You identify, you don't refactor. Nothing here edits code. The report has to survive being pasted into a session that has none of this conversation, which is the real constraint on how long it can be.

## Workflow

1. Get the feature.
2. Find where it lands — one angle, then two more running in the background.
3. Sketch the naive diff — what you'd touch if you just wrote it now.
4. Name the moves that shrink that diff.
5. Report the ones you'd defend.

### 1. Get the feature

The feature, if the user passed one: `$ARGUMENTS`

It may be a path to a SPEC, a slug matching a file in `docs/specs/` (where `/slice` writes), or a sentence. Prose is fine — you need to know what the code has to do, not how it'll be worded. If it's vague enough that you can't guess which files it touches, ask one question rather than reading the whole repo hoping to find out.

### 2. Find where it lands

Three angles, in two waves — the other two are defined in terms of the site's paths, so they can't be dispatched until the site comes back. Every one of them is a subagent: `Explore`, which is read-only, but it does have `Bash`, so tell each plainly to read and report, no command that writes, stages, or checks anything out. Tell each one to read whole files rather than sampling excerpts, ask for exact paths and line numbers over prose, and cap it at the 10 files most worth reading. "The highlighter handles ranges" isn't something you can sketch a diff against, and an agent that sampled its way past half the callers reports the ones it saw without saying it stopped.

Wave one is **the site**: the function, module, or file where this behavior would go, and every caller. Tell the user recon is running, and that the sketch may reach them before the rest of it does.

If the SPEC has a `## Where to look` section, hand those paths to wave one as candidates rather than making it find them cold. They're where an earlier session found the relevant code, not a verdict on the site: that list was written at a commit the section names, and it never had callers as its job. Wave one still has to confirm the site and find every caller, and it can contradict the list.

The moment it lands, dispatch wave two in one message, with the real paths substituted in, then leave both running in the background while you sketch:

- **Prior art.** `git log --oneline -20 -- <the site paths>`, then read the two or three commits that added behavior rather than fixed it. Report each commit's file list.
- **The safety net.** Which tests cover the site, and the command that runs them.

Then read the site files yourself. You can't judge whether a move is behavior-preserving from a summary, and that judgment is the entire value of the report.

Both of wave two have to be in hand before step 4 — wait rather than proceed. If one failed outright, say which one in the report; never fill in what you expect it would have found. If it's the safety net, say that on its own line instead of writing `Covered by: nothing`, which means something specific (see Notes).

If `Explore` isn't available, use the most restricted agent type there is rather than reaching for a general-purpose one. No subagents at all? Say so, then grep and skim the three angles yourself, timeboxed. Slower, and the risk is you stop at the first plausible site instead of the right one.

### 3. Sketch the naive diff

Write out what you would change if you started on the feature right now, save it to a file (`mktemp`), and show it to the user before you read anything else in this skill.

Every line names a real file, a real function, and what you'd add to it — `lib/highlighter.rb:12 CodeHighlighter#call, add a range check inside the map block` — not "update the highlighter."

Do this first because you can't recognize a preparatory refactoring without it. Without the sketch every finding collapses into "this method is long," which is true of the method whether or not the feature exists.

If the sketch comes out small and lands in one place, that's the answer: no preparation, just write it. Say so and stop — but not before prior art is back. A small sketch sitting over commits that each touched five files is the case this skill exists for, and it's the one exit you can't reopen. The highway detour is a loss when the trip is 20 miles.

### 4. Name the moves

Now read `references/tells.md` for the shapes worth looking for.

Wave two is in hand by now. The prior-art file lists are a prediction of which files the naive diff touches: where history touched more files than your sketch does, the code fought back there before and will again, and that's where a move is hiding. The safety net decides what `Covered by:` says, and whether you can call a move behavior-preserving at all.

One to three, and zero is a legitimate result. Every move is behavior-preserving: the tests passing now pass after, unchanged. The moment a move needs a new test it isn't preparation, it's the feature.

**Score each one out of 100** — how sure you are that the move is genuinely behavior-preserving *and* that the feature's diff actually gets smaller. Below 80, drop it without mentioning it. The scarce thing isn't the reader's attention, it's their willingness to detour before starting on what they actually sat down to build. One move they can see the point of gets made; three speculative ones get the whole report ignored.

Judge the detour by what the sketch already tells you rather than estimating code you haven't written: how many files the feature touches, how many call sites move, whether the new behavior becomes a body for one function or edits threaded through several. "Goes from 4 files to 1, at the cost of moving 3 call sites" is checkable. Line counts for unwritten code read as measurements and aren't.

File count is one reading of smaller, not the only one. A seam that never leaves the method it's in still pays when it turns edits threaded through existing lines into a body for a function that already exists — Fowler's `apply_highlights(apply_ranges(lines))` is one file, one method, zero call sites moved, and it's the case this skill is named after. Score that on the shape of the feature's diff, not its address. What disqualifies a same-file move is the feature having to change what the extracted step already does; see the first tell.

### 5. Report

Per move, and nothing around it — no preamble, no summary. Nothing about how you got here either: no note on which angles you dispatched or what tooling you had, no path to the sketch file, no arithmetic behind the confidence number. The reader has a repo and this report, and everything in it has to be something they can act on or check.

```
{the move, one line} · confidence {N}

Today this feature lands as:
  {file}:{line} — {what you'd add}
  {file}:{line} — {what you'd add}

{The move, in a sentence or two, and what the lines above collapse to.}

Covered by: {the command, and what it exercises at the site — or "nothing"}
```

The lines under *today* are the argument, so they name files and functions. If a line could describe any change — messy, clearer, easier to follow — it isn't filled in yet.

They say where the feature's edits land, not how to write them. The report is the case for the move; the feature is someone else's to build, and it's going to `/implement-with-tdd` after this anyway. A helper's body, a guard clause, the expression that does the actual work — leave all of it out, however clearly you can see it. Writing it here adds length the move doesn't need and quietly turns a refactoring report into a half-finished implementation plan.

Close with one line on what to do with it: the refactor is behavior-preserving, so there's no failing test to drive it and it wants a plain session with a green suite. The feature is what goes to `/implement-with-tdd`, afterward.

## Notes

- `Covered by: nothing` is the most useful thing in the report when it's true, and it's only true when the safety-net angle came back and found nothing. It doesn't disqualify the move; it tells the next session to write the characterization tests first. An angle that never reported isn't the same claim, and writing it in that slot ships a false instruction.
- Match the repo's shapes, not your habits. If you're proposing a class where it uses functions, or a module where it uses a table, you've imported an idiom from somewhere else. The refactoring itself doesn't need a precedent — a no-op seam won't have one anywhere — but the thing you create has to look like something this codebase already holds.
- A no-op seam reads as Dead Code to a linter and Speculative Generality to a reviewer, including this repo's own `/multi-lens-review`. Say so in the report if the repo has a coverage gate, so it isn't a surprise.
- Cleanups you notice along the way — dead code, stale comments, a bad name three files over — are real, and they're not this. Keep them out of the numbered moves so the feature's justification stays intact.
- The feature needs one seam. A framework for five more looks like foresight and is a second unreviewable diff.
