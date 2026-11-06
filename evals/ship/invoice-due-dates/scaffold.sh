#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../billing-app.sh"

mkdir -p docs/specs
cat > docs/specs/invoice-due-dates.md <<'MD'
# Invoice due dates

Customers keep asking when an invoice is due. Show it, and flag the late ones.

## Acceptance criteria

- [ ] An invoice is due 30 days after it's issued. One issued on 2026-03-01 is due on 2026-03-31.
- [ ] An unpaid invoice is overdue starting the day after it's due. A paid invoice is never overdue.

## Out of scope

- Late fees and reminder emails.
MD

commit "Add invoice due dates spec"
branch_off invoice-due-dates
