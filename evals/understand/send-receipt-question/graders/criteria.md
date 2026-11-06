---
type: llm
focus: trace
---

`send_receipt` is an `after_commit` callback on create in app/models/order.rb.

PASS if a message from Claude to the user answers that it runs after the order is saved, once the transaction commits.

FAIL if Claude says it runs before the save, or asks the user a question instead of answering.
