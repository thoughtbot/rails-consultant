---
name: multi-lens-review
description: Review a change for defects, then against its spec, its codebase's conventions, the domains trying to emerge from it, and whatever still depends on what it replaced.
argument-hint: "[PR number, branch, or paths to review]"
---

# Code review

Five reviewers, dispatched in parallel, each reading the same change from a different distance:

| Agent | Question |
| --- | --- |
| `agents/defects.md` | Is this code wrong — broken, slow, or exploitable? |
| `agents/spec-fidelity.md` | Did we build what was asked for, and only that? |
| `agents/conventions.md` | Does this look like the rest of the codebase? |
| `agents/domains.md` | Is a domain concept trying to emerge here? |
| `agents/compatibility.md` | Does anything still depend on what this replaced? |

They stay separate so the structural reviewer has nothing cheaper to do. One reviewer asked all five questions spends its attention on naming nits, and never reaches "those five files are one domain object in a trenchcoat."

## The confidence bar

Every finding carries a confidence out of 100: how sure the reviewer is that it's true and that the author would agree it's worth changing. Below 80, the agent drops it without mentioning it. Print the score with each finding so the author can calibrate how much to argue.

What's scarce in a review is the author's trust, not their reading time.

## Workflow

1. Fix the target — one diff, captured once.
2. Find the intent the change was supposed to satisfy.
3. Dispatch the five agents in parallel.
4. Synthesize into one report.
5. Offer the fix.

### 1. Fix the target

`$ARGUMENTS` may hold a PR number, a branch, paths, or nothing. Decide intent-or-target by what a file says, not where it sits: a file that reads as acceptance criteria is the intent, in `docs/specs/` or anywhere else, and a directory or a source path is a target. Ask when a doc argument isn't obviously criteria — reviewing a SPEC file against nothing is a wasted run.

Resolve it to one diff, then capture that diff to a file (`mktemp`) and hand every agent the same path. If each agent runs its own `git diff` instead, one reviews the commits while another reviews the working tree, and their findings won't line up with each other or with what the author sees.

Every target but a PR number needs a base. Resolve it once, and only for those:

```
base=$(git symbolic-ref --short -q refs/remotes/origin/HEAD \
  || git rev-parse --verify -q origin/main \
  || git rev-parse --verify -q origin/master)
```

If that comes back empty, ask which branch to diff against rather than proceeding; the substitution failing silently collapses `git diff $base` into a bare `git diff`, which is unstaged changes only. Don't ask it on a PR number — `gh pr diff` computes its own base, and stalling the run on a question with no bearing on it is worse than not asking.

The agents read whole files around the diff, so the working tree has to be the diff's after-state. Note where you started — `orig=$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)`, because `rev-parse --abbrev-ref HEAD` prints the string `HEAD` on a detached tree and restoring to that is a no-op that looks like it worked.

- A number: `gh pr checkout <n>` first, then `gh pr diff <n>`. Its base is its own, so take it explicitly: `base=$(gh pr view <n> --json baseRefName -q .baseRefName)` — step 4 needs it.
- A branch or ref: `git diff "$(git merge-base <ref> "$base")" <ref>`, and check `<ref>` out.
- Nothing: `git diff "$(git merge-base HEAD "$base")"` — committed and uncommitted both.
- Paths: the same, with `-- <paths>` appended.

Keep the merge-base you computed as `mb`; step 4 checks paths against it.

Either checkout can fail — a dirty tree, a fork whose head isn't fetchable. Stop and say the review can't read the code around the diff. Running on the diff alone reviews it against whatever `HEAD` happened to be, and a checkout that succeeded by carrying uncommitted changes along has left the tree something other than the diff's after-state.

The last two targets need new files staged or they don't appear in the diff at all, and the criterion a new file implements comes back unmet. Record what you touched so you can undo exactly that, before dispatching:

```
new=$(mktemp)
git ls-files --others --exclude-standard -z -- :/ > "$new"
xargs -0 -r git add -N -- < "$new"
# ...capture the diff...
xargs -0 -r git reset -q -- < "$new"
```

The `:/` is what makes it repo-wide. `git ls-files --others` is scoped to the working directory while `git diff` isn't, so run the skill from a subdirectory without it and new files above you stay out of the diff — the exact failure the block exists to prevent.

A bare `git reset` would unstage whatever the author had already staged, which isn't yours to touch. Leaving the marks in place is worse: their next `git commit -a` sweeps in every untracked file in the repo.

Check the result before going further. An empty diff means stop and say so — five agents handed an empty file will find something in the neighboring code they read instead. Past roughly 1500 lines, ask for paths or a commit range; agents silently review the first part of a diff that big and report nothing to say they did.

### 2. Find the intent

Fidelity needs acceptance criteria the change was measured against. Two places hold them: a path in `$ARGUMENTS`, or `docs/specs/`, where `/slice` writes. Match on the branch name or a slug in the commit messages, and if two are close, ask instead of guessing. A PR has both locally, because step 1 checked its branch out.

PR bodies, issues, and commit messages don't count. They describe goals in prose, and prose doesn't draw a scope boundary — so creep is invisible against it, and every finding turns into an argument about what the sentence implied. Criteria or nothing.

If you found a SPEC, check whether it's itself in the diff. A SPEC edited in the same change as the code was either renegotiated in the open or quietly reshaped to match what got built, and only the author knows which — so ask.

**When there's no SPEC.** This is the common case, and the tempting move is to let the agent infer the intent from the diff. Don't. Intent reconstructed from code always matches that code, so the check passes by construction and the author gets a clean bill of health they never earned.

Instead, write the criteria yourself: read the diff and draft the five or six given/when/then lines it looks like it was built from, then show them to the user and ask what's wrong. The corrections are the whole point. A plain list of what the change actually does is the artifact that makes "I never asked for that" obvious, and the user is the only one who can say it. Once they've signed off, those criteria are binding and the agent runs on them normally.

If they'd rather not, skip the agent and say the fidelity check didn't run. An absent check is information; a manufactured pass isn't.

### 3. Dispatch

Read the five agent files and launch them as `Explore` agents in one message so they run concurrently. `Explore` has no `Edit` or `Write` — but it does have `Bash`, so tell each agent plainly: no command that writes, stages, or checks anything out. A reviewer that quietly fixes a finding instead of reporting it is one the author can't learn from.

`agents/defects.md` states a tighter allowlist for itself, since proving a bug is the natural next step for that one. Pass it through as written rather than substituting the looser rule above.

Tell them to read whole files and the whole diff. `Explore` samples excerpts by default, and an agent that reviewed the first third of a diff reports nothing to say so.

Give each the diff path, this skill's own absolute directory — the agent files write it as `{skill_dir}`, so substitute the real path before handing the text over, or the reference file they're pointed at won't resolve from the target repo — and this finding format:

```
{one-line claim}
{locator} · confidence {N}
evidence: {the citation this reviewer's own file demands}
{Why it costs something, in a sentence or two. Name the smell or the convention.}
{The change you'd make.}
```

The locator is `{file}:{line}`, with the line off the new side of the `@@` header plus the offset inside the hunk. Three variants are equally in-format, so step 4 doesn't throw them away: `{file} (in {function or class})` when a line can't be computed — a wrong line number costs the author more than a missing one — one locator per line when a domains finding spans several files, and the same for a conventions comment finding, which `agents/conventions.md` requires to be one per file with a line for each occurrence.

Otherwise, one finding, one issue, one locator — with one exception, a compatibility finding, which carries two because its whole claim is that these two places disagree. An agent that staples three unrelated sites under a single anchor has written something the author can't act on or argue with, and the anchor points at only one of them.

The evidence line is what makes the score checkable. Each agent file says what its own evidence is — a convention needs the path of the file that establishes it, or the named smell plus a line for each occurrence, or nothing at all for a comment finding, which that file exempts; a domain needs its three occurrence sites; a fidelity finding needs the criterion quoted, and quotes no path; a defect needs the trigger plus where the triggering value comes from; a compatibility finding needs the changed line and the thing that still assumes the old behavior. Read the agent's own rule before judging its evidence — holding one to another's is how a valid finding dies in synthesis after the agent was told to file it.

Defect evidence is the weak case, and worth knowing about before you trust it. The other four cite an artifact you can open; a trigger is prose, and its truth is the claim under review. Checking the paths around it is all step 4 can do — so a defect that survives synthesis has been checked less than the findings next to it.

The confidence bar is stated in each agent file; don't restate it here.

The fidelity agent also needs the criteria from step 2, as a path. If they came out of the conversation rather than a SPEC file, write them to a temp file first so the fidelity agent reads a file rather than transcript.

Ask for findings only — no summary, no praise, no "overall this looks good." Some will add it anyway, which is why step 4 throws it away rather than trusting the instruction.

### 4. Synthesize

Lead with what you reviewed: the target, the intent source and its kind, and a one-line verdict a person can act on. Say up front if a check didn't run — a review missing its fidelity pass looks identical to one that passed it, unless you name the difference.

Then the findings under five headings, numbered continuously across all five so step 5 has something unambiguous to name. Defects come first because they're the ones with a cost attached to shipping, and compatibility second for the same reason: both cost something the moment this ships, where the other three cost something later. Sort inside each heading by highest confidence — except defects, which sort by consequence first: a confidence-95 off-by-one in a log line sits below a confidence-82 unbounded delete, and confidence alone puts them the wrong way round.

Discard an agent's preamble, summary, and verdict rather than editing them down. Drop a finding whose evidence line is missing, and check the paths it does cite — the locator's file, the occurrence sites on a domains finding, and both locators on a compatibility one, unless it says outright that the surviving dependent is outside this repo and it couldn't check. A fidelity finding cites no path at all, so there's nothing to check there and nothing to drop it for.

Check a path against the diff and the merge-base — `git cat-file -e "$mb:<path>"` — not against the working tree. A change that deletes a file produces legitimate findings citing a path that's no longer on disk, and an unset `$mb` turns that command into a check against the index, which quietly passes for everything the current branch tracks. If you don't have a merge-base, don't run the check.

Don't drop a finding over the shape of its locator line; step 3 allows three. An agent arguing for its own finding is the one party with a reason to round its score up, so the number can't be the filter; the citation can.

A finding filed under the wrong heading moves; it doesn't get dropped. The conventions agent reporting a SQL injection found a real defect — file it under defects, next to whatever the defects agent said about the same lines.

Two agents often catch the same code from different heights — duplication as a smell and as an unnamed domain. Where one fix settles both, keep the higher-altitude version and drop the other, because the author fixes it once. Where the two fixes are different edits, keep both: a wrong return value and a long method live on the same lines and neither one resolves the other.

Defects also collide the other way, with a finding that argues the opposite. The clearest case: defects reports a fallback that quietly returns a wrong answer, and fidelity reports that same error handling as scope nobody asked for. One says fix it, the other says delete it. Report both, adjacent, and name the conflict — dropping either leaves the author fixing a bug in code that shouldn't exist, or deleting a path something now depends on.

Compatibility collides with defects most often, and the two findings are usually the same line seen from either side of the deploy. Defects reports a read that returns nothing; compatibility reports the column the same diff dropped out from under it. Keep compatibility's version — it names the window, which is the part that decides what order to ship in — and drop defects'. Where the defect is true even after the rollout finishes, they aren't the same finding and both stay.

If every agent came back empty, say that plainly. A review with nothing in it is a real result, and padding it with observations you scored below the bar is how the bar rots.

### 5. Offer the fix

Ask which of the numbered findings to apply. Don't apply them unasked: a reviewer who edits starts defending its own edits, and the author loses the chance to say "that's deliberate, here's why."

Apply only what they name, one finding at a time, and stop if a fix turns out to be bigger than the finding described.

Then put the branch back — `git checkout "$orig"` — unless you applied something. Uncommitted fixes don't survive a checkout: it either refuses and you've said you restored when you didn't, or it carries the edits onto `$orig` and the branch they were meant for still has the bug. When you've applied a fix, say which branch the edits are on and leave the operator there.

## Notes

- `agents/defects.md` stands in for the built-in `/code-review`, and adds the security pass that lives in `/security-review`. Two things it doesn't do: it can't execute anything, so every defect is a claim with a trigger attached rather than a demonstrated failure, and its confidence bar cuts recall the built-in would keep at high effort. On a change where a missed bug is expensive, run the built-in too.
- The agents run read-only, so anything they'd change comes back as a recommendation rather than a diff. If `Explore` isn't available, say so and pick the most restricted agent type there is rather than reaching for a general-purpose one.
- Nothing here assumes a language or a framework, and the review is worse the moment it starts to. Whatever pattern you're about to recommend, point at the place this repo already does it. If you can't find one, you're recommending a habit from somewhere else.
- `agents/` holds prompt fragments, not registered subagents — no frontmatter, nothing validates them. What an agent can touch comes from the agent type dispatch launches, not from anything declared in those files.
- The noise rules — lockfiles and generated files, findings a linter already gives away free, dimensions that aren't yours — are stated in each of the five agent files rather than here, because the agents never read this one. A rule an agent has to follow and can't see is a rule that doesn't exist.
