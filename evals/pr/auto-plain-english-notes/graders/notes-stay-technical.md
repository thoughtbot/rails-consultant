---
type: llm
---

Find the line note about the shipped email going out again when a shipped order is saved later. It starts with a label like `**Risk:**`.

PASS if that note's first sentence names code, like `after_save`, `shipped_at`, `ship!`, or `OrderMailer`.

FAIL if it doesn't, or there's no such note.
