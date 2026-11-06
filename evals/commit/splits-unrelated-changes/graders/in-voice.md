---
type: llm
focus: trace
---

Look at the commit messages in the `git commit` commands Claude ran. Ignore the `Co-Authored-By:` trailer.

thoughtbot's voice: speaks as "we" for the team, never "I"; numerals for counts ("2 tests", not "two tests"); no emoji. A number that starts a sentence may be spelled out ("Two titles can ...").

PASS if no message says "I", spells out a count of 2 or more as a word mid-sentence, or uses an emoji.

FAIL if any message does, or Claude ran no `git commit`.
