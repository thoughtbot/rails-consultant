---
type: llm
focus: { source: file, path: lib/invoice.rb }
---

This is the `Invoice` class after building a SPEC with two criteria: an invoice is due 30 days after it's issued, and an unpaid invoice is overdue starting the day after it's due. Before the change it had `amount_cents`, `pay`, `paid?`, and readers for `plan`, `issued_on`, and `paid_on`.

PASS if every public method added to the class is about the due date or about being overdue.

FAIL if it adds a public method for anything else, such as late fees or reminders.
