---
type: llm
---

Judge only the PR body, the description the reply hands back, usually in a fenced block. Line notes tied to a file and line aren't the body.

The body may end with a line saying which Claude model wrote it. That line is meant to be there; judge the body without it.

PASS if the PR body explains why the change exists and stays short, under about 15 lines of prose. A sentence on what changes for customers or staff is fine.

FAIL if the body walks through what changed file by file, lists the files or methods added, or repeats what the diff already shows.
