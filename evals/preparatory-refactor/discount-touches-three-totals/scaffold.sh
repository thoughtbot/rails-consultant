#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../shop-app.sh"

mkdir -p docs/specs
cat > docs/specs/discount-codes.md <<'MD'
# Discount codes

Customers can enter a discount code at checkout to take a percentage off their order.

## Behavior

- A discount code has a code string (like `SPRING10`) and a percent off (1 to 100).
- An order can have at most one discount code.
- The percent comes off the line item subtotal. Tax and the free-shipping threshold use the discounted subtotal.
- The amount we charge, the receipt email, and the PDF invoice all show the same discounted total, with a "Discount" line between subtotal and tax.
- Codes are case-insensitive.

## Out of scope

- Expiring codes, usage limits, fixed-amount discounts.
MD

commit "Add discount codes spec"
