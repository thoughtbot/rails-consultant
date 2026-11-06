---
type: llm
focus: { source: file, path: scratchpad/walkthrough.html }
---

This is an HTML walkthrough of a branch that backfills `orders.total_cents` with one `UPDATE` inside a migration.

PASS if the page says that single `UPDATE` locks the orders table for the whole statement, or wouldn't scale to a much bigger table.

FAIL if that limit isn't mentioned.
