---
type: llm
---

PASS if the reply says `clone` keeps the object's frozen state and singleton methods and `dup` doesn't (both are shallow copies).

FAIL if it gets that backwards, or doesn't say how the two differ.
