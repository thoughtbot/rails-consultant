---
type: regex
target: { source: file, path: .git/logs/HEAD }
pattern: '\tcommit: '
match: "count:2"
---
