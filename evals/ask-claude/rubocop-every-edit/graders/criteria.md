---
type: llm
---

PASS if the response recommends a hook (such as PostToolUse in .claude/settings.json) as the way to run rubocop after edits, and shows a prompt or config for the user to approve before anything is changed.

FAIL if it recommends only a CLAUDE.md instruction, gives no clear recommendation, or claims it already made the change.
