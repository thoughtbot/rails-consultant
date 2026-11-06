---
type: regex
target: { source: file, path: scratchpad/walkthrough.html }
pattern: '\b(rails|heroku|active ?record|active ?job|sidekiq|before_action|rack|dyno)\b'
flags: i
match: not_contains
---
