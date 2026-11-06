---
type: llm
---

The PR body is the description the reply hands back, usually in a fenced block. Notes tied to a file and line, and anything after the fenced block, are not the body.

PASS if the body's last paragraph says Claude wrote it and names the specific model, such as "Claude Opus 5.5", "Claude Sonnet 4.5", or a model ID like `claude-opus-5-5`. Any model name or ID counts, even one you don't recognize. The paragraph may wrap onto two lines.

FAIL if the body has no such paragraph, it says only "Claude" or "Claude Code" with no model, or other body content (a checklist, a `Closes` line) comes after it.
