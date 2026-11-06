---
description: The user is sure the receipt goes out from a before_save, but it's an after_commit, so the skill's first turn asks one short question that makes them test that belief instead of correcting it.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

Help me understand how order receipts get sent in this app. Next I'm adding a card charge that runs in the same transaction as the order save, and if the charge fails the whole thing rolls back. My worry is that the receipt goes out from a before_save on Order, so a customer whose charge failed would still get a receipt. I want to understand it well enough to know if I have to move it.
