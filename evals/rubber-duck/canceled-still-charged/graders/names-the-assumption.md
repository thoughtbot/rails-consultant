---
type: llm
focus: trace
---

The user's reasoning rests on one unchecked belief: that renewals go through `renew!`. They read the model, not whatever does the renewing.

PASS if a message from Claude to the user points at that belief, that renewals go through `renew!`, as the part they haven't confirmed.

FAIL if no message singles it out, or a message settles it by telling them whether it's true.
