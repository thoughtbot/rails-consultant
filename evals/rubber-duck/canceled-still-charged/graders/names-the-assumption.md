---
type: llm
focus: trace
---

The user's reasoning rests on one unchecked belief: that renewals go through `renew!`. They read the model, not whatever does the renewing.

The skill's first reply may be only a reflection: it plays the user's reasoning back in their terms and stops, so they hear the gap themselves. That counts as naming it, as long as the belief is one of the links it plays back.

PASS if a message from Claude to the user either points at that belief as the part they haven't confirmed, or plays their chain back with that belief stated as one of its links (like "every renewal goes through `renew!`") without vouching for it.

FAIL if no message mentions renewals going through `renew!`, or a message settles it by telling them whether it's true, such as "renewals do go through `renew!`" or "the job skips `renew!`".
