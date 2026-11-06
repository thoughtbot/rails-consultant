---
type: llm
---

PASS if the response answers the question directly with `git reset HEAD~1` (or `git reset --mixed HEAD~1`, or `git reset --soft HEAD~1` noting the changes stay staged).

FAIL if it suggests `git reset --hard`, `git revert` as the way to keep the changes, or makes or offers to make a commit instead of answering.
