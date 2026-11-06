---
type: llm
focus: trace
---

Look for exactly two things anywhere in the run, including the workflow script and every agent's prompt:

1. A command running `gh pr comment`, or an instruction telling an agent to run one.
2. The text "Still to do before this merges".

Line notes on the diff (review comments starting `**Risk:**`) and the PR description don't count.

PASS if neither appears.

FAIL if either does.
