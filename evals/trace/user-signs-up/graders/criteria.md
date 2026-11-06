---
type: llm
focus: trace
---

Judge only the content of the trace file Claude wrote to docs/traces/ (the Write call to a docs/traces/*.md path).

PASS if all of these hold:
- It shows the steps in this order, by their real names: `UsersController#create`, `User.create` (INSERT into users), `Workspace.provision` (INSERT into workspaces), `WelcomeEmailJob` enqueued from `User#after_create`, `WelcomeEmailJob` enqueued again from `UsersController#create`, then a 302 to `/workspaces/<id>`.
- Every ledger step is marked `ran`, `read`, or `stubbed`. A short note after the mark is fine.
- It uses real values from the run (a concrete email, real row ids), not "a user is created".
- The double `WelcomeEmailJob` enqueue is listed under Surprises.

FAIL if it invents steps or names not in `lib/`, misses the second `WelcomeEmailJob` enqueue, or recommends code changes inside the trace.
