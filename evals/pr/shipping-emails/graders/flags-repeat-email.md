---
type: llm
focus: trace
---

The branch adds `after_save :send_shipped_email, if: -> { shipped_at.present? }` to `Order`. Once an order has shipped, every later save sends the shipped email again, for example when an admin edits the order's notes.

PASS if a message from Claude to the user points out that the shipped email can go out again on later saves of a shipped order.

FAIL if no message from Claude points that out.
