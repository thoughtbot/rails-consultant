---
type: regex
target: trace
pattern: '"name":"(?:Read|Grep|Glob|Bash)","input":\{[^}\n]*?app/jobs'
match: not_contains
---
