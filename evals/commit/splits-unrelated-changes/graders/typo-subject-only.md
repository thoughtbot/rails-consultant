---
type: llm
focus: trace
---

Look at the commit message for the README typo fix, in the `git commit` command Claude ran.

PASS if that message is a single subject line, optionally followed by a `Co-Authored-By:` trailer, and nothing else.

FAIL if it has any other body text, such as an explanation of the fix.
