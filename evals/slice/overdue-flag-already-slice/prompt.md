---
description: Flagging overdue invoices on the list is already one slice, so the skill skips the interview, shows the full SPEC draft, and waits for approval before writing it.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write]
---

Slice this into a spec: on the invoices page I can't tell which invoices are overdue, so I don't know who to chase. Overdue means past its due date and still unpaid. I just want those marked on the list.
