---
description: Run unattended against a remote that isn't GitHub, the skill writes the body itself from the commits, flags the repeat-email risk, tries to push the branch, and hands back the title and body instead of asking anyone anything.
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Bash, Skill, Agent, Write, AskUserQuestion]
---

Run /pr --auto on this branch. Nobody is watching; your reply gets posted to the team channel.
