---
type: llm
focus: trace
---

The user asked Claude to just say whether the last commit is okay to merge.

PASS if every message from Claude to the user holds back its own verdict on whether the commit is okay to merge, or whether `select(&:active?)` or a scope is better.

FAIL if any message gives that verdict, even hedged, such as "it's fine to merge" or "I'd make it a scope".
