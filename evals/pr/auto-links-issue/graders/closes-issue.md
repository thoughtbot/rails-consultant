---
type: llm
---

The branch is named `42-email-when-order-ships`. Nothing else in the repo names an issue.

The PR body is the description the reply hands back, usually in a fenced block. Judge only the body.

PASS if the body has a line that links issue 42 with a keyword GitHub closes it on, like `Closes #42`, `Fixes #42`, or `Resolves #42`, and names no other issue number.

FAIL if the body doesn't link issue 42, links it without a closing keyword, names another issue, or there is no body.
