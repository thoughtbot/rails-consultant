---
type: llm
focus: trace
---

The call notes use the floor staff's own words: belay check, green tag, orange tag, pull their tag, retest, re-up, outside tags.

PASS if a message from Claude to the user plays back a list of terms from the notes, written the way the notes write them, such as "pull their tag" and "re-up".

FAIL if no message has such a list, or the list swaps in tidier words instead, such as certification, revoke, or recertify.
