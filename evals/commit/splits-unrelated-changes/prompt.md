---
description: A feature plus an unrelated typo fix should become two atomic commits, with only the user's reason in the body.
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

I added a slugify helper so post URLs stop breaking on titles with spaces, and fixed a typo in the README while I was in there. Commit my changes.
