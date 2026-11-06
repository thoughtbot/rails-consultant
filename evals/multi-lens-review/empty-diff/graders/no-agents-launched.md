---
type: regex
target: trace
pattern: '"type":"tool_use","id":"[^"]*","name":"(?:Agent|Task)"'
match: not_contains
---
