# Rails Consultant

A collection of [skills][] for Rails development and consulting, with an
emphasis on learning, communication, and client success.

[skills]: https://code.claude.com/docs/en/skills

## Installation

Stay tuned. We first need to [submit][] to the offcial marketplace.

[submit]: https://code.claude.com/docs/en/plugins#submit-your-plugin-to-the-official-marketplace

## Commands

### Understanding the Codebase

| Command      | Description                                                                                                                                                                                                                              |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/explain`   | Explains a specific piece of code or a user-facing flow. Point it at a file, class, or method for a close reading; point it at a feature or user action for a system-level diagram with entry points, branching logic, and side effects. |
| `/prior‑art` | Finds every place the codebase handles a specific concern — the consistent pattern and the exceptions. Answers the "how does this app do X?" question before you build something that reinvents it.                                      |

### Test-Driven Development

| Command                    | Description                                                                                                                                                                                                                                                                                                    |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/test‑driven‑development` | Strict outside-in TDD workflow for Rails. Starts with a feature spec describing behavior from the user's perspective, lets each failure guide what to build next, and drops to unit tests for non-trivial logic. Enforces the discipline: no production code without a failing test first. Red-green-refactor. |

### Code Quality

| Command            | Description                                                                                                                                                                                                                                                                                                          |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/socratic‑review` | A pairing session, not a report. Reads the code silently, then leads you to see the issues yourself through questions — whether it's your own code, a teammate's PR, or something you inherited. Names smells and moves precisely, then closes with a concrete plan: what to fix, in what order, and where to start. |

### Planning

| Command  | Description                                                                                                                                                                                                                                                                                                                                                                                        |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/slice` | Turns a feature into well-defined, independently shippable slices — whether it's an epic that needs breaking apart or a single story that needs sharpening into a job story. Works Socratically: guides you to find the slices yourself, validates each against the "can it ship independently?" and "can a user see the value?" tests, then helps you sequence by risk and learning, not by ease. |

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
