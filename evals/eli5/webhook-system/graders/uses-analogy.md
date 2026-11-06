---
type: llm
---

Look at the reply's prose (ignore the code blocks).

PASS if it explains the system with a simple analogy from everyday life outside software, the kind a kid would follow: a mailroom clerk who writes down each letter's tracking number and bins any second copy, a cashier who won't refund the same receipt twice, a guest list at a door. The analogy has to be stated in plain words and map onto how this code works (the same message can arrive more than once, and a remembered ID makes the repeat get skipped).

FAIL if there is no such analogy, if the only comparisons are to other software, code or a framework (a unique index, a Rails callback, a background job, a cache), or if the comparison is so loose it doesn't map onto skipping repeats.
