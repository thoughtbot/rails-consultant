---
type: llm
---

The SPEC adds a minimum length of 3 to `Product#name` in app/models/product.rb. The repo also has order total math copied into `Order`, `OrderMailer`, and `InvoicePdf`, which this feature doesn't touch.

PASS if the reply proposes no refactor at all. A side note that unrelated code could be cleaned up some other time is fine.

FAIL if it proposes any refactor to do before this feature, such as consolidating the order total math or changing `Product`.
