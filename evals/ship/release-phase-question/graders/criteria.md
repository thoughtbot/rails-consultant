---
type: llm
---

PASS if the reply says the release phase runs the command on the Procfile's `release:` line before the new code goes live, and that `rails db:migrate` is a common thing to run there.

FAIL if it gets either one wrong, or starts building or shipping something instead of answering.
