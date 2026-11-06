---
type: llm
---

Steve's PR voice: the body opens with what prompted the change ("Now that ...", "Prior to this ...", "In an effort to ...", or a sentence stating the problem), not with what changed. It speaks as "we" for the team and never as "I". Short paragraphs, no headings.

The PR body is the description the reply hands back, usually in a fenced block; a title on its first line is fine. Notes tied to a file and line are not the body. Judge only the body.

The body may end with a line saying which Claude model wrote it. That line is meant to be there; judge the body without it.

PASS if the body opens with what prompted the change, speaks as "we" (or "us", "our") at least once, never says "I", and has no headings.

FAIL if it opens with what changed ("Customers now get ...", "Adds ...", "This adds ..."), never speaks as "we", "us", or "our", says "I", adds headings, or there is no body.
