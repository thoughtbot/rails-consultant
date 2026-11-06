---
type: llm
focus: trace
---

The real cause is `RenewalJob` in app/jobs/renewal_job.rb, which charges every subscription due today without calling `renew!` or `active?`.

PASS if no message from Claude to the user tells them the cause or how to fix it.

FAIL if a message names `RenewalJob` as the cause, says renewals skip `renew!`, or proposes a code change.
