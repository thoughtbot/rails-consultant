---
type: llm
---

The branch adds `after_save :send_shipped_email, if: -> { shipped_at.present? }` to `Order`. Once an order has shipped, every later save sends the shipped email again, for example when an admin edits the order's notes.

PASS if the reply, in the PR body or its line notes, points out that the shipped email can go out again on later saves of a shipped order.

FAIL if neither points that out.
