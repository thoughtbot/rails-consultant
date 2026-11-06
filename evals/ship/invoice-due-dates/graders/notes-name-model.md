---
type: llm
focus: trace
---

The run ends with notes for the PR: risks, tradeoffs, and open questions tied to a file and line. Use the last set: the `notes` the `open:check` agent returned if it returned any, else the `notes` the `open:pr` agent sent. That includes any note the check agent added or rewrote.

PASS if every note in that set ends with a line naming the specific Claude model, such as "Claude Opus 5.5" or a model ID like `claude-opus-5-5`. Any model name or ID counts, even one you don't recognize.

FAIL if any note lacks that line, says only "Claude" or "Claude Code" with no model, or there are no notes.
