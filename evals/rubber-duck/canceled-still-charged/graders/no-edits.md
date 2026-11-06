---
type: regex
target: trace
pattern: '"name":"(?:Edit|Write)","input":\{"file_path":"[^"]*/app/'
match: not_contains
---
