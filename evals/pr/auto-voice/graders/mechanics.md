---
type: llm
---

thoughtbot's writing mechanics: numerals for counts ("3 orders", not "three orders"), no emoji, and at most one exclamation point per paragraph.

Judge the PR body the reply hands back and the line notes tied to a file and line. Ignore code blocks, drawings, and the attribution lines naming the model.

PASS if no count of 2 or more is spelled out as a word ("two", "three", "ten") mid-sentence (one that starts a sentence is fine), there's no emoji, and no paragraph has more than one exclamation point. "One" as a word is fine.

FAIL if any of those slip, or there is no body.
