---
description: A small SPEC on a feature branch goes through the whole chain unattended, ends tested, committed and pushed, and the reply hands back a draft PR and says what nobody checked outside the tests.
max_turns: 80
timeout_seconds: 3600
allowed_tools:
  [Read, Glob, Grep, Skill, Bash, Write, Edit, Workflow, AskUserQuestion]
tags: [regression]
---

Ship docs/specs/invoice-due-dates.md.
