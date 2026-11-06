---
type: llm
---

Ignore fenced code blocks; those hold a PR title and body for the user to paste.

PASS if everything outside the fenced blocks is 15 lines or fewer, counting each bullet and each paragraph line as one.

FAIL if it's longer, or if it has a section per step (Prepare, Implement, Review, Verify, Open) whether or not that step needs anything from the user.
