---
type: regex
target: { source: file, path: .git/index }
pattern: 'docs/specs/'
match: not_contains
---
