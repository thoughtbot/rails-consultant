---
type: llm
---

The repo's `.github/pull_request_template.md` has three sections, in this order: `## Why`, `## How to check it`, `## Checklist`.

The PR body is the description the reply hands back, usually in a fenced block. Judge only the body.

PASS if the body has those three headings, in that order, each with content under it, and adds no headings of its own.

FAIL if a heading is missing, renamed, out of order, or empty, the body adds a heading the template doesn't have, or there is no body.
