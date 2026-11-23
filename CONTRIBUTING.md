# Contributing

We love contributions from everyone.
By participating in this project,
you agree to abide by the thoughtbot [code of conduct].

[code of conduct]: https://thoughtbot.com/open-source-code-of-conduct

We expect everyone to follow the code of conduct
anywhere in thoughtbot's project codebases,
issue trackers, chatrooms, and mailing lists.

## Contributing Code

Fork the repo.

We recommend using [Skill Creator] to draft, test, and iterate on skills. It
provides a structured workflow for writing skill prompts, running evaluations,
and optimizing skill descriptions for accurate triggering.

[Skill Creator]: https://claude.com/plugins/skill-creator

Mention how your changes affect the project to other developers and users in the
`NEWS.md` file.

Push to your fork. Write a [good commit message][commit]. Submit a pull request.

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give constructive feedback.
This is a time for discussion and improvements,
and making the necessary changes will be required before we can
merge the contribution.

## Versioning

This plugin follows [semantic versioning] (`MAJOR.MINOR.PATCH`) in
`.claude-plugin/plugin.json`. Claude Code uses this version to decide whether
to update a cached plugin.

[semantic versioning]: https://semver.org

For a skills-only plugin like this one, the traditional notion of "backward
compatibility" doesn't quite apply — skills are prompt text, not code with APIs,
and a rewording can meaningfully change behavior. Here's how we apply semver:

- **MAJOR** — rename, remove, or fundamentally restructure a skill that users
  may depend on.
- **MINOR** — add a new skill or meaningfully update an existing one.
- **PATCH** — fix typos, update descriptions, or make trivial adjustments.

Merging to `main` doesn't ship anything. Each marketplace that lists this
plugin, like [thoughtbot/skills], pins it to a release tag, so users get a new
version only when we move that pin:

```json
"source": {
  "source": "github",
  "repo": "thoughtbot/rails-consultant",
  "ref": "v2.1.0"
}
```

Feature pull requests don't touch the version. Add a note under
`## [Unreleased]` in `NEWS.md` and leave it there.

To release:

1. Open a pull request that bumps `version` in `.claude-plugin/plugin.json` and
   renames `## [Unreleased]` in `NEWS.md` to `## [x.y.z] - YYYY-MM-DD`, with a
   new, empty `## [Unreleased]` above it. Merge it.
2. On the merged `main`, run:

       bin/release

   This reads the version from `plugin.json`, creates an annotated `vx.y.z` tag,
   and pushes it.

3. Open a pull request in each marketplace setting this plugin's `ref` to
   `vx.y.z`.

[thoughtbot/skills]: https://github.com/thoughtbot/skills

See [obra/superpowers] for a reference example of how a mature Claude Code plugin
handles versioning, release notes, and git tags.

[obra/superpowers]: https://github.com/obra/superpowers
