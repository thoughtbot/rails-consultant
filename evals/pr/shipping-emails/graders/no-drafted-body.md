---
type: llm
focus: trace
---

PASS if no message from Claude to the user contains a PR description for this branch written by Claude. A suggested title and short notes on what changed and its risks, given as background for the user, don't count.

FAIL if any message contains a drafted description, a fill-in template (such as Summary / Changes / Testing headings), or an example description.
