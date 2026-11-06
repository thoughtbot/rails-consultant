---
name: trace-user-signs-up
description: Tracing sign-up should run it in development and write a ledger with real names and values to docs/traces/.
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill]
---

Trace what happens when a user signs up in this app. Run it, don't just read the code.
