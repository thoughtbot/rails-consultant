---
type: llm
focus: trace
---

The user believes the receipt is sent from a `before_save` on Order. It's actually sent from `after_commit :send_receipt, on: :create` in app/models/order.rb, so a rolled-back order sends no receipt.

PASS if a message from Claude to the user asks a question that makes them test that belief, such as what happens to the receipt when the transaction rolls back.

FAIL if Claude answers it for them instead, by saying a rollback sends no receipt or that they don't need to move it.
