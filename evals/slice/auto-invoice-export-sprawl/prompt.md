---
description: The same sprawling invoice export idea, run unattended from a GitHub issue, so the skill cuts scope without asking, records its guesses, and replies with the full SPEC instead of writing a file.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, AskUserQuestion]
tags: [regression]
---

Run /slice --auto on this GitHub issue. Your reply gets posted back to the issue as a comment.

<issue>
Our accountant keeps asking for invoices. I want invoice export: CSV and PDF, filter by date range, and a monthly email that sends the export to the accountant automatically.
</issue>
