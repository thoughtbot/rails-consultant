## [Unreleased]

## [1.5.0] - 2026-07-30

- Ground `/slice` in the codebase before it starts slicing. Phase 1 now ends with
  an optional step that fans out subagents to find whether the feature already
  exists, what's reusable, and how comparable features are tested — the last of
  which is what turns vague acceptance criteria into concrete ones. The findings
  are there to sharpen the Socratic questions, not to answer them, and the step
  stands down for greenfield work or when the conversation already carries a
  codebase map.
- Rework `/feature-dev`'s handoff into slicing now that `/slice` grounds itself.
  Phase 2 is that grounding, so Phase 3 explicitly skips `/slice`'s version of it
  rather than paying for the same exploration twice, and uses it as a checklist
  instead: if Phase 2 missed what already exists or what the real edge cases are,
  fill the gap before writing acceptance criteria.

## [1.4.0] - 2026-07-29

- Make `/socratic-review`'s Step 0 assessment concrete about how it fans out. It
  now names the `Agent` tool and the `general-purpose` agent type instead of
  vaguely saying "dispatch subagents," hands each subagent a bundled brief
  (`references/smell-explorer.md`) alongside its problem space, and requires the
  orchestrator to read the key files itself before opening the session — the
  session discusses and then changes that code, which can't be done from
  severity labels and `file:line` pointers alone.

## [1.3.1] - 2026-07-18

- Fix `/feature-dev` erroring at the slicing phase: it invoked `slice` and
  `test-driven-development` through the Skill tool, but both are user-invoke-only
  (`disable-model-invocation`) and the tool rejects them. Those phases now follow
  each skill's `SKILL.md` directly, and the workflow spells out which skills the
  Skill tool can reach and which must be followed inline.

## [1.3.0] - 2026-07-17

- Add the `/feature-dev` skill: a guided end-to-end workflow that takes a single
  feature slice from idea to reviewed, committed code, chaining `/slice` →
  `/test-driven-development` → code review → `/git-commit`. It stays scoped to one
  slice (an epic prompt makes it help you pick the slice to build now), keeps the
  implementation diff lean against a ~300-line production-code budget, and closes
  with Claude Code's built-in `/code-review --fix` before verifying the suite is
  green.

## [1.2.0] - 2026-07-17

- Add the `git-commit` skill: `/git-commit` reads the working tree, groups
  related changes into atomic commits, and writes each message in the thoughtbot
  style — explaining the why, flagging risks and surprises, and keeping a
  cohesive feature in one commit while splitting unrelated work apart.

## [1.1.0] - 2026-06-12

- Fan out subagents for the `socratic-review` skill's silent assessment: large or
  unfamiliar targets (multi-file PRs, SHAs, inherited code) are now explored by
  parallel subagents — one per problem space — whose findings are merged into the
  private ranked list, while small targets are still read inline.

- Strengthen the `test-driven-development` skill's outside-in workflow: run the
  affected test after every change and let the failure dictate the next move, and
  write a new failing test at each layer you drop into (e.g. a request spec before
  building a controller) rather than treating lower layers as covered by the
  feature spec.

## [1.0.0] - 2026-03-25

Initial release.
