---
type: llm
---

PASS if the reply lists at least one note tied to a file and line in the branch's diff, such as `app/models/order.rb:4`, and labeled as a risk, tradeoff, or open question.

FAIL if risks and tradeoffs only appear as a list in the PR body, or there are no notes.
