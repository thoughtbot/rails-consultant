---
type: regex
target: trace
pattern: '"name":"(?:Read|Grep|Glob|Bash)","input":\{[^\n]*?\bapp/'
match: not_contains
---
