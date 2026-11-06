---
type: llm
focus: { source: file, path: scratchpad/walkthrough.html }
---

This is an HTML walkthrough of a branch that stores order totals in a new `orders.total_cents` column, kept current by `LineItem` callbacks.

PASS if the page warns that `total_cents` can go stale when line items change without running callbacks (for example `update_column`, `update_all`, `insert_all`, or the nightly import task).

FAIL if that risk isn't mentioned.
