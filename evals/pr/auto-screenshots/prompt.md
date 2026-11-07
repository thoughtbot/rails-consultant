---
description: Screenshot URLs passed with --screenshots get embedded in the body as-is, and the skill takes, uploads, and commits no images of its own.
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Bash, Skill, Agent, Write, AskUserQuestion]
tags: [regression]
---

Run /pr --auto --screenshots https://example.com/shipped-email.png on this branch. Nobody is watching; your reply gets posted to the team channel.
