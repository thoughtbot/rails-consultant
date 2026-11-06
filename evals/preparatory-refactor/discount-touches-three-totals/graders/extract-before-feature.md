---
type: llm
focus: trace
---

The discount SPEC changes the order total. Today the total math lives in three copies: `Order#total_cents`, `OrderMailer#receipt`, and `InvoicePdf`.

PASS if a message from Claude to the user recommends, as a step before building discount codes, putting the total math in one place that the mailer and the invoice call instead of their own copies.

FAIL if no message from Claude recommends a refactor first.
