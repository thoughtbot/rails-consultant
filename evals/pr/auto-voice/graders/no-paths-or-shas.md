---
type: llm
---

The PR body is the description the reply hands back, usually in a fenced block; a title on its first line is fine. Notes tied to a file and line, like `app/models/order.rb:4: **Risk:** ...`, are line notes, not the body, even when they're meant to be posted on the PR. Judge only the body.

The body may end with a line saying which Claude model wrote it. That line is meant to be there; judge the body without it.

PASS if the body names no file paths (like `app/models/order.rb` or `docs/specs/shipping.md`) and no commit SHAs (like `e5aede9`).

FAIL if the body contains a file path or a commit SHA, even in parentheses as a source, or there is no body.
