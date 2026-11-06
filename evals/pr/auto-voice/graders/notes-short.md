---
type: llm
---

Line notes are the comments tied to a file and line. Each starts with a label like `**Risk:**`, `**Tradeoff:**`, or `**Open question:**`. A note's first paragraph is the one that starts with that label. Ignore everything after it: the plain-English paragraph, any drawing, and the attribution line.

Count sentences in each note's first paragraph. A question counts as a sentence. A code snippet in a fenced block is not a sentence.

PASS if every note's first paragraph is one or two sentences.

FAIL if any note's first paragraph has three or more sentences, or there are no notes.
