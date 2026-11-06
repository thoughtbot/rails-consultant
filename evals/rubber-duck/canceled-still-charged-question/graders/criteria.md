---
type: llm
focus: trace
---

PASS if a message from Claude to the user says the cause is `RenewalJob` charging subscriptions due today without checking `active?` or going through `renew!`.

FAIL if no message names that cause, or Claude asks the user questions instead of finding it.
