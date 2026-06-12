## [Unreleased]

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
