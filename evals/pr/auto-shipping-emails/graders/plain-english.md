---
type: llm
---

Picture the support lead at this shop. They answer customer emails and have never read the code.

The PR body is the description the reply hands back, usually in a fenced block; a title on its first line is fine. Notes tied to a file and line, like `app/models/order.rb:4: **Risk:** ...`, are line notes, not the body, even when they're meant to be posted on the PR. Judge only the body.

The body may end with a line saying which Claude model wrote it. That line is meant to be there; judge the body without it.

PASS if that person could read the body and know what changes for customers or staff, and why. It names no classes, methods, or other code (like `Order`, `after_save`, or `OrderMailer`) and uses no programmer terms (like callback, mailer, migration, column, or enqueue).

FAIL if the body uses any code name or programmer term, describes the change in terms of the code instead of the people using the shop, or there is no body.
