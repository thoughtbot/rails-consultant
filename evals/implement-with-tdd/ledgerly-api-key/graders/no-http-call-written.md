---
type: regex
target: trace
pattern: '"name":"(?:Write|Edit)","input":\{[^\n]*?(?:Net::HTTP|[Ll]edgerly|LEDGERLY)'
match: not_contains
---
