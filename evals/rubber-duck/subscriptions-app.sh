#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q -m "$1"; }

mkdir -p app/models app/jobs

cat > README.md <<'MD'
# Boxly

A Rails 8 app for monthly snack box subscriptions. Run the tests with `bin/rails test`.
MD

commit "Set up the app"

cat > app/models/subscription.rb <<'RUBY'
class Subscription < ApplicationRecord
  belongs_to :customer

  scope :due_today, -> { where(renews_on: Date.current) }

  def active?
    canceled_at.nil?
  end

  def cancel!
    update!(canceled_at: Time.current)
  end

  def renew!
    return unless active?

    PaymentGateway.charge(customer, price_cents)
    update!(renews_on: renews_on.next_month)
  end
end
RUBY

commit "Add subscriptions"

cat > app/jobs/renewal_job.rb <<'RUBY'
class RenewalJob < ApplicationJob
  def perform
    Subscription.due_today.find_each do |subscription|
      PaymentGateway.charge(subscription.customer, subscription.price_cents)
      subscription.update!(renews_on: subscription.renews_on.next_month)
    end
  end
end
RUBY

commit "Renew subscriptions nightly"
