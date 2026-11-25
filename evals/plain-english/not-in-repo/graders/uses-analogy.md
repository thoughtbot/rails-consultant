---
type: llm
---

Look at the reply's prose (ignore the code blocks).

PASS if it explains feature flags with a simple analogy from everyday life outside software, the kind a kid would follow: a light switch on a wall, a "closed" sign on one door of a shop, a dish a restaurant only serves to some tables. The analogy has to be stated in plain words and map onto how a feature flag works (the thing is built and in place, and a switch decides who gets it, without rebuilding anything).

FAIL if there is no such analogy, if the only comparison is to other software, code or a framework (an `if` statement, an environment variable, a Rails config setting), or if the comparison is so loose it doesn't map onto switching something on or off.
