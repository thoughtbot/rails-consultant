---
type: llm
focus: trace
---

Look at the `git add` and `git commit` commands Claude ran.

PASS if README.md (a typo fix) was committed on its own, and lib/slug.rb, lib/post.rb, and test/slug_test.rb were committed together in a separate commit.

FAIL if README.md shares a commit with any lib/ or test/ file, or the test file is in a commit without lib/slug.rb.
