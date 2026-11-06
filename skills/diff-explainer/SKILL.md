---
name: diff-explainer
description: Builds a shareable HTML walkthrough of the current changes, highlighting risks, tradeoffs, and alternatives considered.
argument-hint: "[PR number, branch, or paths to explain]"
---

# Diff explainer

The diff already shows what changed. What it can't show is why — why this approach
and not the obvious one, what broke when you tried that, what you're nervous about,
what you decided not to do. Supply that. Your reader is a sharp, time-poor developer
who may not know this stack.

## 1. Work out what you're explaining

No argument means the current branch against its base, diffed from the merge base
so other people's commits don't leak in.

```bash
BASE=$(git rev-parse --verify --quiet @{upstream} \
    || git rev-parse --verify --quiet refs/remotes/origin/HEAD \
    || git rev-parse --verify --quiet refs/heads/main \
    || git rev-parse --verify --quiet refs/heads/master)
MB=$(git merge-base "$BASE" HEAD)
test -n "$MB" || echo "No base found — ask which branch to diff against."
git diff --stat "$MB" && git log --oneline "$MB"..HEAD
git status --porcelain -uall   # untracked files the diff won't show
```

Size up the change from the stat before reading `git diff "$MB"` — a diff you pull
into context whole is one you can no longer decide to skip. Upstream first, and
`refs/heads/` not bare `main`, or you diff against the wrong base: a fork of
`develop` drags in everyone's `develop` commits, a trunk named anything else finds
no base at all, and a _tag_ called `main` beats the branch of the same name. Empty
`$MB` also means an unborn HEAD — no commits yet, nothing to explain.

`git diff "$MB"` covers committed and uncommitted work both, so a branch with no
commits of its own still works. An argument overrides. Resolve it as a rev first
(`git rev-parse --verify --quiet <arg>`); anything else is a path, and goes after
`--` so a `docs` branch and a `docs/` directory can't collide. A bare number is a
PR (`gh pr diff <n>`, plus `gh pr view <n>` for the body and linked issue) unless a
branch by that name exists; with no working `gh`, say so and take the branch. If the
change is obvious — a version bump, a typo — say so and skip the artifact.

## 2. Who's reading

Explain the change in this stack's own terms unless you know the reader's
background: the user named it ("for a WordPress developer"), or their instructions
say what they know. Don't guess one, and don't default to a popular framework. If
the project is already in their stack, write plainly, no framework comparisons.
If it isn't, translate each unfamiliar concept into their terms inline, in the
annotation where the reviewer meets it. Never build a glossary or translation
table: that makes them hold a mapping and look things up, where an analogy in the
sentence costs nothing.
Read `references/translation.md` first: it covers how to use an analogy without it
becoming noise.

## 3. Gather the why

If the change was made in this session, that's your best source by far — what got
tried and thrown away, what surprised you, none of which survives in the diff.
Otherwise reconstruct from commits, the PR body, the linked issue, and surrounding
code, then ask the author — two sharp questions beat a page of confident guessing.

**Never invent rationale.** A plausible why that's wrong is worse than none, because
the reviewer approves on it. If you can't establish why, leave it unannotated or say
plainly that it isn't recorded anywhere. If you find a real bug while writing up,
tell the user directly rather than burying it in a note they may skim.

## 4. Choose the annotations, then write them

Show the whole diff; annotate only where you have something to say — a decision, a
risk, a tradeoff, an abandoned alternative. A change that looks wrong until you know
the reason, or a deletion that looks unrelated, is a decision. Skip renames,
formatting, and mechanical churn. Generated files get one line saying so and an
`<em>` elision line inside the `<pre><code>` instead of their diff.

The pull toward over-annotating is strong, since every hunk has _something_ sayable.
Resist it: a walkthrough beats the raw diff only by being shorter than it, so a big
diff gets a shorter page, not a longer one. Ten annotations read beat thirty
skimmed. Before publishing, delete every annotation a competent reviewer would
already know, or wouldn't review any differently for — that pass is where most of
the value gets made. **Order the steps as an argument, not an alphabetical
listing:** lead with the file where the change actually lives, group files that only
make sense together, and if B must be understood before A means anything, B first.

Write each annotation in one to three sentences; a longer one is usually two, or a
paragraph belonging in "Start here". If a sentence would still be true with the diff
hidden, it's a _what_ and can go. The ones that earn their place are the ones an
author would rather not write — this is a workaround, this gets slow at 10x the
data — and the dead ends, since "we tried X, it failed because Y" pre-empts the
reviewer's first suggestion. Write in thoughtbot's [voice and tone][voice]:
conversational, "we" for the team, contractions, short sentences, numerals (3, not
three), sentence-case headings, no emoji. Plain words: no "it's worth noting",
"this ensures".

**Open with the problem and one analogy.** The reviewer may have no context on the
problem this branch solves, and a mechanism means nothing until they know what
went wrong. So "Start here" leads with the problem in plain words (what a user
saw, what someone needed), then one comparison from everyday life a kid would
follow, both before any file, class or code name. Sessions held in each server's
memory are a coat check where each attendant keeps the tickets in their own
pocket: one goes home at shift change, and every coat they took in is stranded.
Map its pieces onto the real ones, then say where it breaks if the gap will bite.
One analogy, in "Start here" only; the annotations stay in the code's terms. This
isn't step 2's framework translation: it explains the problem, not the stack, so
it's there whoever the reader is. If the user asks for no analogies, skip it.

**Draw the baseline.** The reviewer can't judge a change without knowing what it
changed from, and the diff only shows the seams. So "Start here" gets one
before/after `<figure>`: how the thing worked on the base branch, how it works now.
Draw the mechanism, not the file list — boxes are what holds state or does work (a
process, a table, a job, a request), arrows are what moves between them. Keep the
same boxes in the same places on both sides so the eye lands on the difference, and
mark only the difference: `<del>` for what's gone, `<ins>` for what's new. They mean
removed and added, never bad and good, and anything both sides share stays bare. A
risk or alternative gets its own small pair only when its point is a change of
shape — a new failure path, the design you didn't build — with labels that say so
("After: Redis blips", "Signed cookies"); there, mark what differs within that pair
(the stale price, the lost job), not the feature "Start here" already marked, and
never `<del>` on a design that was never built. Nesting means containment, so a
shared store sits outside both processes and gets drawn once. One
diagram per note at most, most notes none. A number on one side (p95 2.4s) needs its
counterpart from the PR on the other, or neither side gets one. Plain ASCII (`-->`,
`+`, `|`), under ten lines and 44 characters a side, since each side stacks
full-width on a phone; break a long chain rather than widen it. Box-drawing
characters are raw bytes and turn to mojibake like any other. A change with no shape to draw — copy, a bug fix inside one
method — gets no figure; don't draw two identical boxes to fill the slot.

## 5. Fill in the template and publish

`assets/walkthrough-template.html` is the page, and its own comment lists the
elements. Its `<style>` block is the whole design, so there are no layout classes to
choose: pick the element that describes the content — `<ins>` and `<del>` for diff lines,
`<aside data-note>` for an annotation — and leave the `<style>` block alone, so every
walkthrough reads the same way. Everything inside `<main>` is a worked example —
replace it. Three calls the comment doesn't make: the `<hgroup>` carries the change's
_name_, two to four words, not a summary; the watch list `<dl>` holds the two to four
things a reviewer would regret missing; and the `data-note` kinds are color-coded, so
pick the one that's true. Four things reliably spoil the page: unescaped `&`, `<`, `>`
in diff lines; raw typographic characters (write `&mdash;`, `&minus;`, `&hellip;` —
these pages get saved locally, where raw multi-byte characters turn into mojibake);
leftover example content; and the template's instruction comment.

**The page ends when the diff ends.** No verdict, recommendation, "where I'd most
like a second opinion", or pre-approval checklist — each hands the reviewer your
conclusion and invites them to ratify it, the opposite of a review. Disclose, don't
steer: "this makes Redis a hard dependency for booting healthy, so a blip takes the
whole app down" is a fact they'd have to dig for; "that's the call I'd like you to
sign off on" steers. What the branch deliberately doesn't do is a fact too: put it
in "Start here", without "easy to add if you'd rather".

Write the filled page to your scratchpad as `walkthrough.html` and publish it with
the Artifact tool (favicon `🔍`, a one-sentence description, the change's name as
the title) and hand over the link. If your environment wants `artifact-design`
loaded first, load it, but keep the template's `<style>` block: it is this page's
design system.

[voice]: https://thoughtbot.com/playbook/the-thoughtbot-way/brand/voice-and-tone
