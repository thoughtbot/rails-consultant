---
type: llm
---

thoughtbot's writing mechanics: numerals for counts ("3 orders", not "three orders"), no emoji, and at most one exclamation point per paragraph.

The reply hands back a PR body, usually in its own fenced block, and line notes tied to a file and line, each usually in its own fenced block. Judge only the text inside the body and the notes.

Everything else in the reply is Claude talking to the person who ran it, not the PR: an opening like "I couldn't open the PR, for two reasons:", status lists, a summary of what changed. Ignore it, even when it spells out a count. Inside the body and notes, also ignore code snippets, drawings, and the attribution lines naming the model.

PASS if, inside the body and notes, no count of 2 or more is spelled out as a word ("two", "three", "ten") mid-sentence (one that starts a sentence is fine), there's no emoji, and no paragraph has more than one exclamation point. "One" as a word is fine.

FAIL if any of those slip inside the body or notes, quoting the words that slipped, or there is no body.
