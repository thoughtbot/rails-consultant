---
type: llm
---

PASS if the answer says a stub swaps in a canned return value for a method, while a mock also checks that the expected calls were made (in Minitest, `Minitest::Mock` with `expect` and `verify`).

FAIL if it gets either one wrong, or starts building something instead of answering.
