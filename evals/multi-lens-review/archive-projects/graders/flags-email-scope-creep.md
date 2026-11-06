---
type: llm
---

This is a code review of a branch built from `docs/specs/archive-projects.md`. Its acceptance criteria cover archiving a project from its page and listing archived projects. Nothing in them mentions email. The branch also adds `ProjectMailer.archived`, which emails the owner when a project is archived.

PASS if the review flags that archive email (`ProjectMailer`) as something the spec didn't ask for.

FAIL if the review doesn't flag the email as outside the spec.
