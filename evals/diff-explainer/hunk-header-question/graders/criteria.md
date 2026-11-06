---
type: llm
---

PASS if the response explains that `-12,7` means the hunk starts at line 12 of the old file and covers 7 lines, and `+12,9` means it starts at line 12 of the new file and covers 9 lines.

FAIL if it gets either range wrong, or offers to build a walkthrough or explain a branch instead of answering.
