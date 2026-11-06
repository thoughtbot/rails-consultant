---
description: Run unattended, the skill writes the body and the line notes in thoughtbot's voice from the guide built into it, without borrowing the guide's examples.
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Bash, Skill, Agent, Write, AskUserQuestion]
---

Run /pr --auto on this branch. Nobody is watching; your reply gets posted to the team channel.
