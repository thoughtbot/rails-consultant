## [Unreleased]

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
