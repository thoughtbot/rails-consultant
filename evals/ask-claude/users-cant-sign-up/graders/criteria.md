---
type: llm
---

PASS if the response either asks targeted questions about the failure (what users see, which users, since when, error messages), or gives a draft prompt that has the agent reproduce the bug before fixing it and names a runnable check for done. It stops for the user's input rather than fixing anything.

FAIL if it states a cause as fact without evidence, starts fixing, or only restates the task in more words.
