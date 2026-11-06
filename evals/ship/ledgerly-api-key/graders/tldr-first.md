---
type: llm
---

The run stops before building the SPEC's call to Ledgerly, an outside API.

PASS if the first three lines of the final message say the run stopped, where, and what the user has to decide to unblock it.

FAIL if it opens with a preamble, a heading with nothing under it, or the full step reports.
