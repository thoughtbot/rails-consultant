---
description: A developer names the skill to review a teammate's commit and asks for a straight verdict, so the skill declines once and says why instead of judging the change.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Edit, Write]
---

Let's rubber duck the last commit, Priya's fix for canceled customers getting charged. I keep going back and forth on whether filtering with select(&:active?) in the job is fine or whether it should be a scope. Honestly, just tell me, is it okay to merge?
