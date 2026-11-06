#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../subscriptions-app.sh"

git config user.name "Priya Natarajan"
cat > app/jobs/renewal_job.rb <<'RUBY'
class RenewalJob < ApplicationJob
  def perform
    Subscription.due_today.select(&:active?).each do |subscription|
      PaymentGateway.charge(subscription.customer, subscription.price_cents)
      subscription.update!(renews_on: subscription.renews_on.next_month)
    end
  end
end
RUBY

commit "Skip canceled subscriptions when renewing"
