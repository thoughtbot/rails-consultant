---
type: llm
---

The reply is a GitHub comment. The SPEC sits between a `<!-- spec -->` line and a `<!-- /spec -->` line.

PASS if the reply's last paragraph comes after the `<!-- /spec -->` line, says Claude wrote it, and names the specific model, such as "Claude Opus 5.5", "Claude Sonnet 4.5", or a model ID like `claude-opus-5-5`. Any model name or ID counts, even one you don't recognize. The paragraph may wrap onto two lines.

FAIL if there's no such paragraph, it says only "Claude" or "Claude Code" with no model, it sits inside the SPEC, or other content comes after it.
