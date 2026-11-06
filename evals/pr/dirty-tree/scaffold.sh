#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../shop-app.sh"

cat > app/views/order_mailer/shipped.text.erb <<'ERB'
Good news: order #<%= @order.id %> shipped on <%= @order.shipped_at.to_date %>.

Reply to this email if anything looks wrong.
ERB
