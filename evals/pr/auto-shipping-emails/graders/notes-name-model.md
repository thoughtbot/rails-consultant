---
type: llm
---

Notes are the risks, tradeoffs, and open questions the reply ties to a file and line, such as `app/models/order.rb:4`.

PASS if every note says Claude wrote it and names the specific model, such as "Claude Opus 5.5", "Claude Sonnet 4.5", or a model ID like `claude-opus-5-5`; any model name or ID counts, even one you don't recognize. Each note carries its own line, since each one shows up on GitHub on its own.

FAIL if any note lacks that line, says only "Claude" or "Claude Code" with no model, or there are no notes.
