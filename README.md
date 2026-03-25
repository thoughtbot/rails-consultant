# Rails Consultant

A collection of [skills][] for Rails development and consulting, with an
emphasis on learning, communication, and client success.

## Installation

Add the marketplace to Claude Code:

```
/plugin marketplace add thoughtbot/thoughtbot-plugins
```

Install the plugin:

```
plugin install rails-consultant@thoughtbot-plugins
```

## Commands

### Understanding the Codebase

#### `/explain`

Explains a specific piece of code or a user-facing flow. Point it at a file, class, or method for a close reading; point it at a feature or user action for a system-level diagram with entry points, branching logic, and side effects.

```
/explain app/models/user.rb
/explain password reset
/explain the Stripe webhook handler
```

#### `/prior‑art`

Finds every place the codebase handles a specific concern — the consistent pattern and the exceptions. Answers the "how does this app do X?" question before you build something that reinvents it.

```
/prior-art How does this app handle authorization?
/prior-art Where do we send transactional emails?
/prior-art How are background jobs retried on failure?
```

### Test-Driven Development

#### `/test‑driven‑development`

Strict outside-in TDD workflow for Rails. Starts with a feature spec describing behavior from the user's perspective, lets each failure guide what to build next, and drops to unit tests for non-trivial logic. Enforces the discipline: no production code without a failing test first. Red-green-refactor.

```
/test-driven-development Users can cancel their subscription from the billing page
/test-driven-development Fix the bug where archived projects still appear in search results
```

Based on [Superpowers][superpowers] by Jesse Vincent, adapted for Rails with guidance from [Testing from the Outside-In][outside-in], [The Testing Pyramid][testing-pyramid], and [Testing Antipatterns][antipatterns].

### Code Quality

#### `/socratic‑review`

A pairing session, not a report. Reads the code silently, then leads you to see the issues yourself through questions — whether it's your own code, a teammate's PR, or something you inherited. Names smells and moves precisely, then closes with a concrete plan: what to fix, in what order, and where to start.

```
/socratic-review app/services/payment_processor.rb
/socratic-review the open PR on branch feature/notifications
/socratic-review I inherited this controller and something feels off
```

### Planning

#### `/slice`

Turns a feature into well-defined, independently shippable slices — whether it's an epic that needs breaking apart or a single story that needs sharpening into a job story. Works Socratically: guides you to find the slices yourself, validates each against the "can it ship independently?" and "can a user see the value?" tests, then helps you sequence by risk and learning, not by ease.

```
/slice Users need to be able to manage their subscription
/slice We need an admin dashboard for customer support
/slice Add multi-tenancy to the existing app
```

Inspired by [Break Apart Your Features into Full-Stack Slices][full-stack-slices] and [Job Stories][job-stories] from the thoughtbot Playbook.

### Thinking and Decisions

#### `/rubber‑duck`

Socratic friction to help you find clarity, not sympathy. Follows your thinking with one question at a time — the actual problem underneath, what you've already ruled out, what your gut says. Closes with an honest synthesis and one question you've been avoiding.

```
/rubber-duck I can't decide between a service object and a concern here
/rubber-duck I keep going back and forth on whether to extract this into a gem
/rubber-duck
```

#### `/challenge`

Cross-examines a belief, design decision, or inherited constraint. Asks where it came from, what evidence would change it, and what the simplest alternative is. Has opinions — says directly when an assumption is weak and names the better path.

```
/challenge We need microservices because the monolith won't scale
/challenge We can't use Hotwire because our UI is too complex
/challenge The client says we have to support IE11
```

### Client Communication

#### `/standup`

Writes a polished, ready-to-send client update. Checks git for context, then asks what the code can't tell: what you actually spent time on, what the client must know, what risks you might be softening. Pushes on internal team communication too — not just what goes to the client.

```
/standup
/standup We spent most of the day debugging a production issue with Sidekiq
```

#### `/hard‑news`

A prep session before a difficult client conversation. Asks you to write your opening sentences before polishing them — then uses what comes out to show you how you instinctively handle pressure. Produces the opening, explanation, path forward, likely reactions, and specific phrases to avoid.

```
/hard-news The launch date is going to slip by two weeks
/hard-news We found a security vulnerability in production
/hard-news We need to recommend rewriting a module the client just paid for
```

#### `/offboard`

Walks through the Designer/Developer wrap-up checklist for offboarding a client engagement — one item at a time, assisting where it can (scanning for secrets, checking branches, reviewing the README). No documents produced; the conversation is the deliverable.

```
/offboard
/offboard We're wrapping up the Acme Corp engagement this Friday
```

## Recommended Plugins

The commands in Rails Consultant pair well with the following plugins.

- [Code Review][code-review]
- [Code Simplifier][code-simplifier]
- [Context7][context7]
- [Explanatory Output Style][explanatory-output-style]
- [Security Guidance][security-guidance]

## Common Workflows

### Feature development

1. Use `/slice` to break down a feature or epic into a
   [Full-Stack Slice][full-stack-slices].
1. Use `/test-driven-development` to drive out the implementation by [testing from the outside-in][outside-in] using the [testing pyramid][testing-pyramid].
1. Use `/simplify` to refactor the shameless green implementation.

### Code review

1. Use `/explain` to help you understand the change.
1. Use `/socratic-review` to deliberately slow down and get a better
   understanding
   of the PR yourself.
1. Use [`/code-review`][code-review] only after you've given your own feedback.

## Contributing

See the [CONTRIBUTING][] document.
Thank you, [contributors][]!

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

[CONTRIBUTING]: CONTRIBUTING.md
[antipatterns]: https://thoughtbot.com/upcase/videos/testing-antipatterns
[code-review]: https://claude.com/plugins/code-review
[code-simplifier]: https://claude.com/plugins/code-simplifier
[community]: https://thoughtbot.com/community?utm_source=github
[context7]: https://claude.com/plugins/context7
[contributors]: https://github.com/thoughtbot/rails-consultant/graphs/contributors
[explanatory-output-style]: https://claude.com/plugins/explanatory-output-style
[full-stack-slices]: https://thoughtbot.com/blog/break-apart-your-features-into-full-stack-slices
[hire]: https://thoughtbot.com/hire-us?utm_source=github
[job-stories]: https://thoughtbot.com/playbook/rapid-product-validation/jtbd#how-to-write-and-use-job-stories
[outside-in]: https://thoughtbot.com/blog/testing-from-the-outsidein
[security-guidance]: https://claude.com/plugins/security-guidance
[skills]: https://code.claude.com/docs/en/skills
[superpowers]: https://github.com/obra/superpowers/blob/main/skills/test-driven-development/SKILL.md
[testing-pyramid]: https://thoughtbot.com/blog/rails-test-types-and-the-testing-pyramid
