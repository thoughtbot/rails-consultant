---
description: Asked in plain words to score against `release`, the skill fires and diffs from there, leaving out the release branch's own session and Gemfile changes.
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Bash, Skill]
tags: [regression]
---

How risky is this branch compared to release? Our CI job pipes your reply straight into jq.
