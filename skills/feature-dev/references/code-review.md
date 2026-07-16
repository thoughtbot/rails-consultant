# Code Review Standard

Background for Phase 5. The review itself is delegated to Claude Code's built-in `/code-review` command (run at a level, with `--fix` to auto-apply). This file documents the standard that review applies — the same confidence-based approach the feature-dev `code-reviewer` agent uses — so you understand what it's weighting, and so you can fall back to a manual review if the built-in command isn't available in the environment.

## Scope

Review the diff for the slice just built — `git diff` against the branch point, or the specific files changed. Do not review pre-existing code outside the slice; a problem that was already there before this work is out of scope unless the slice made it materially worse.

## What to review

**Project guidelines compliance.** Verify adherence to explicit project rules — typically `CLAUDE.md` or equivalent — covering import patterns, framework conventions, Ruby/Rails style, error handling, logging, testing practices, and naming. In a Rails app this includes fat-model/skinny-controller boundaries, proper use of scopes and validations, strong params, and the app's established service/query-object patterns.

**Bug detection.** Real bugs that will hit in practice — logic errors, nil handling, N+1 queries, missing database indexes on new lookups, race conditions, mass-assignment or authorization gaps, and security vulnerabilities.

**Code quality.** Significant issues only — duplication, missing critical error handling, accessibility problems in views, and inadequate test coverage for a behavior the slice introduced.

## Confidence scoring

Rate each potential issue 0–100:

- **0** — Not confident. A false positive that doesn't survive scrutiny, or a pre-existing issue.
- **25** — Somewhat confident. Might be real, might be a false positive. If stylistic, not called out in project guidelines.
- **50** — Moderately confident. Real, but a nitpick or rare in practice. Low importance relative to the rest of the diff.
- **75** — Highly confident. Double-checked; very likely real and will be hit in practice. The current approach is insufficient, or it's directly named in project guidelines.
- **100** — Certain. Confirmed it will happen frequently; the evidence directly confirms it.

**Only report issues with confidence ≥ 80.** Quality over quantity. A review that lists twenty maybes trains the developer to ignore reviews; a review that names three real problems gets acted on.

## Output for each reviewer

State what you reviewed. For each issue at confidence ≥ 80, give:

- A clear description with the confidence score.
- File path and line number.
- The specific guideline reference or a concrete explanation of the bug.
- A concrete fix.

Group by severity — **Critical** (bugs, security, data integrity) vs. **Important** (quality, conventions, coverage). If nothing clears the bar, say so and confirm the slice meets standards with a one-line summary.

## After the review

The built-in `/code-review --fix` applies the confirmed fixes itself, so there's no findings list to consolidate by hand. Two things still matter once it's done, and they're spelled out in Phase 5 of `SKILL.md`: re-run the full suite to confirm the slice is still green, and if a fix changed behavior that no test yet covers, add the missing test (failing first) so the correction can't silently regress.

If you're doing a **manual fallback** (the command isn't available): review the slice diff against the standard above, keep only confidence ≥ 80, group by severity, and apply the fixes test-first — any behavior change gets a failing test before the fix.
