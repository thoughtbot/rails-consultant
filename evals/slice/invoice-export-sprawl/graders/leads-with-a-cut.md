---
type: llm
focus: trace
---

The user asked for invoice export as CSV and PDF, a date range filter, and a monthly email to the accountant.

PASS if a message from Claude to the user proposes leaving at least one of those named parts out of the first slice, stated as its own call that the user can push back on.

FAIL if no message proposes a cut, or the messages only ask the user which parts to include.
