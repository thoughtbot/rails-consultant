---
type: llm
focus: trace
---

The user said: "I added a slugify helper so post URLs stop breaking on titles with spaces, and fixed a typo in the README while I was in there."

Look at the commit messages in the `git commit` commands Claude ran.

PASS if every reason given for making the change is the user's (URLs breaking on titles with spaces), or no reason is given. Describing what the code does, its limitations, risks, or what wasn't tested is not a reason and is fine.

FAIL if a message claims the change was made for a reason the user never gave, such as SEO, readability, consistency, performance, or best practice.
