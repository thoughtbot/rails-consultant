# Rails Consultant

A collection of [skills][] for Rails development and consulting, with an
emphasis on learning, communication, and client success.

[skills]: https://code.claude.com/docs/en/skills

## Installation

Stay tuned. We first need to [submit][] to the offcial marketplace.

[submit]: https://code.claude.com/docs/en/plugins#submit-your-plugin-to-the-official-marketplace

## Commands

### Understanding the Codebase

| Command      | Description                                                                                                                                                                                                                                |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/onboard`   | The 30,000-foot view before touching anything. Explores architecture, conventions, key models, infrastructure, test health, and risk signals. Start here on a new engagement.                                                              |
| `/explain`   | Translates a specific piece of code into plain understanding — what it does and why, not whether it's good. Checks git history first so the "why" behind the code isn't lost.                                                              |
| `/flow`      | Traces a user flow through the codebase and renders it as an ASCII call graph: routes → controller → service objects → models → jobs and mailers. Surfaces branch points, side effects, and recent git changes for every file in the path. |
| `/prior‑art` | Finds every place the codebase handles a specific concern — the consistent pattern and the exceptions. Answers the "how does this app do X?" question before you build something that reinvents it.                                        |

### Test-Driven Development

| Command                    | Description                                                                                                                                                                                                                                                                                                    |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/test‑driven‑development` | Strict outside-in TDD workflow for Rails. Starts with a feature spec describing behavior from the user's perspective, lets each failure guide what to build next, and drops to unit tests for non-trivial logic. Enforces the discipline: no production code without a failing test first. Red-green-refactor. |

### Code Quality

| Command            | Description                                                                                                                                                                                                                                                                                                          |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/audit`           | A systematic sweep across eleven problem spaces: responsibility, coupling, security, data integrity, edge cases, error handling, performance, testing, design, duplication, and Rails patterns. The "I don't know what I don't know" tool.                                                                           |
| `/socratic‑review` | A pairing session, not a report. Reads the code silently, then leads you to see the issues yourself through questions — whether it's your own code, a teammate's PR, or something you inherited. Names smells and moves precisely, then closes with a concrete plan: what to fix, in what order, and where to start. |

### Planning

| Command  | Description                                                                                                                                                                                                                                                                                                                                                                                        |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/slice` | Turns a feature into well-defined, independently shippable slices — whether it's an epic that needs breaking apart or a single story that needs sharpening into a job story. Works Socratically: guides you to find the slices yourself, validates each against the "can it ship independently?" and "can a user see the value?" tests, then helps you sequence by risk and learning, not by ease. |

### Learning

| Command  | Description                                                                                                                                                                                                                                                                           |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/spike` | Teaches a new technology or framework: the 20% mental model that unlocks 80% of real usage, anchored to what you already know in Rails. Corrects misconceptions first, then covers core concepts, Rails-developer gotchas, and a concrete first thing to build.                       |
| `/tutor` | Teaches a specific concept encountered mid-work — not by explaining it, but by making you attempt it first, then calibrating your attempt precisely and correcting the underlying mental model. The goal is to understand it well enough to write it without looking it up next time. |

### Thinking and Decisions

| Command        | Description                                                                                                                                                                                                                                                            |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/rubber‑duck` | Socratic friction to help you find clarity, not sympathy. Follows your thinking with one question at a time — the actual problem underneath, what you've already ruled out, what your gut says. Closes with an honest synthesis and one question you've been avoiding. |
| `/challenge`   | Cross-examines a belief, design decision, or inherited constraint. Asks where it came from, what evidence would change it, and what the simplest alternative is. Has opinions — says directly when an assumption is weak and names the better path.                    |

### Client Communication

| Command      | Description                                                                                                                                                                                                                                                                                                                        |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/standup`   | Writes a polished, ready-to-send client update. Checks git for context, then asks what the code can't tell: what you actually spent time on, what the client must know, what risks you might be softening. Pushes on internal team communication too — not just what goes to the client.                                           |
| `/hard‑news` | A prep session before a difficult client conversation. Asks you to write your opening sentences before polishing them — then uses what comes out to show you how you instinctively handle pressure. Produces the opening, explanation, path forward, likely reactions, and specific phrases to avoid.                              |
| `/offboard`  | Wraps up an engagement with three documents: a technical handoff for the next developer, a plain-language summary for stakeholders, and a set of questions to discuss in the final client meeting. Explores the codebase and git history for context, then asks what you're most worried about — and pushes past the first answer. |

## License

Rails Consultant is Copyright (c) thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About thoughtbot

![thoughtbot](https://thoughtbot.com/thoughtbot-logo-for-readmes.svg)

This repo is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community].
We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
