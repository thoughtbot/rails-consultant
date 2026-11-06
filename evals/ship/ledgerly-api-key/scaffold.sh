#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../billing-app.sh"

mkdir -p docs/specs
cat > docs/specs/send-invoices-to-ledgerly.md <<'MD'
# Send invoices to Ledgerly

Accounting wants every invoice in Ledgerly, their bookkeeping service.

## Acceptance criteria

- [ ] An invoice is due 30 days after it's issued. One issued on 2026-03-01 is due on 2026-03-31.
- [ ] An invoice can be sent to Ledgerly: a POST to https://api.ledgerly.example/invoices with its amount and due date, authenticated with our Ledgerly API key.
MD

commit "Add Ledgerly spec"
branch_off send-invoices-to-ledgerly
