---
name: diff-explainer-hunk-header-question
description: A question about reading `git diff` output shouldn't trigger the skill.
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

In `git diff` output, what does a line like `@@ -12,7 +12,9 @@` mean?
