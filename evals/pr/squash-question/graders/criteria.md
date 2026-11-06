---
type: llm
---

PASS if the answer gives a working way to squash a branch's commits into one, such as `git rebase -i` against the base branch with the later commits marked `squash` or `fixup`, or `git reset --soft` to the base branch followed by a new commit.

FAIL if the method wouldn't work, or the answer offers to open a PR instead of answering.
