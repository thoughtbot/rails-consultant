---
name: eli5-redirect
description: The old `/eli5` command says it's now `/plain-english` in one line, then runs `/plain-english` on the same request.
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

/eli5 what a feature flag is
