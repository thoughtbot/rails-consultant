---
type: regex
target: { source: file, path: .git/index }
pattern: '\.(?:png|jpe?g|gif|html|diff|patch|log)\x00|(?:tmp|log|screenshots)/'
match: not_contains
---
