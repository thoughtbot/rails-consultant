---
type: llm
---

The repo's only remote is a local folder, so `gh` can't open a PR there.

PASS if the final message gives a PR URL, or says the PR wasn't opened and gives a title and a description body ready to paste.

FAIL if it points to an artifact or walkthrough page instead, or gives neither a PR nor a title and body.
