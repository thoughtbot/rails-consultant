---
type: llm
---

PASS if the response answers directly: e.g. call `.to_sql` on the relation, or set `ActiveRecord::Base.logger = Logger.new($stdout)` (the development console usually logs SQL already).

FAIL if it offers to run a scenario, write a trace to docs/traces/, or answers with anything other than how to see the SQL.
