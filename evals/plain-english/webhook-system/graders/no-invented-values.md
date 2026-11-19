---
type: llm
---

Everything that exists in this repo:

- Values: `SEEN_TTL_SECONDS = 72 * 60 * 60` (72 hours, 259200 seconds), event IDs `evt_3QmX81` (type `invoice.paid`, invoice 7302, appears twice in the fixture) and `evt_3QmY04` (type `customer.updated`), return values `:duplicate`, `:ignored`, `:processed`, handler types `invoice.paid` and `charge.refunded`, the README's "for up to 3 days".
- Code names: `Webhooks::Processor`, `Webhooks::SeenStore`, `Webhooks::HANDLERS`, `call`, `seen?`, `remember`, `fetch`, `@store`, `@handlers`, `@clock`, `@expires_at`, `ttl`.
- Files: README.md, lib/webhooks/processor.rb, lib/webhooks/seen_store.rb, lib/webhooks/handlers.rb, test/fixtures/events.json.

Judge only the specific values, names and files the reply presents as this repo's, not its claims about how the code behaves.

PASS if each one is in that list or follows from it, such as a time computed from 72 hours, or a file:line citation into those files.

FAIL if the reply presents any value, name or file as this repo's that isn't there, such as a different TTL, event ID, route, controller or database table. Values clearly marked as a general or outside example don't count.
