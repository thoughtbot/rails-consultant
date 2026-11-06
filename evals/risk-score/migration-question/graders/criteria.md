---
type: llm
---

PASS if the answer says running code can still reference the column after it's dropped, and recommends telling ActiveRecord to ignore it first (`ignored_columns`) and dropping it in a later deploy.

FAIL if it scores a diff, or offers a risk score, instead of answering.
