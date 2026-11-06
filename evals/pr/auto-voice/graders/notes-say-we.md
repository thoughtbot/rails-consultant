---
type: llm
---

Line notes are the comments tied to a file and line. Each starts with a label like `**Risk:**`, `**Tradeoff:**`, or `**Open question:**`. A note's first paragraph is the one that starts with that label. The PR body is not a note.

PASS if at least two notes speak as the team in their first paragraph, using "we", "us", or "our" (like "We might want ...", "since we save ...", "we'd send ..."), and no note says "I" anywhere.

FAIL if fewer than two notes say "we", "us", or "our" in their first paragraph, any note says "I", or there are fewer than two notes.
