---
type: llm
focus: { source: file, path: scratchpad/walkthrough.html }
---

This is an HTML walkthrough of a branch that stops creating a note from waiting on the mail provider: the digest email now goes on a queue and gets sent later.

PASS if the "Start here" section explains the problem with one simple analogy from everyday life outside software, the kind a kid would follow (a waiter who clips the order to the rail and walks away instead of standing at the stove, a cashier who hands back the receipt and mails the warranty card later, or similar). It has to map onto this change: the person asking used to wait on a slow step, and now that step happens after they leave.

FAIL if there is no such analogy, if the only comparisons are to software or a framework (a background job, Sidekiq, a cron), or if the comparison doesn't map onto the waiting going away.
