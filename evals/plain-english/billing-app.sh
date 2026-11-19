#!/usr/bin/env bash
# Builds a tiny Ruby subscription-billing app that uses the word "dunning". No gems, no network.
set -euo pipefail

mkdir -p bin db lib/billing lib/mailers

cat > lib/billing/subscription.rb <<'RUBY'
module Billing
  class Subscription
    attr_reader :customer, :plan, :monthly_cents
    attr_accessor :status

    def initialize(customer:, plan:, monthly_cents:)
      @customer = customer
      @plan = plan
      @monthly_cents = monthly_cents
      @status = :active
    end

    def suspend!
      self.status = :suspended
    end
  end
end
RUBY

cat > lib/billing/invoice.rb <<'RUBY'
module Billing
  class Invoice
    attr_reader :number, :subscription, :amount_cents, :failed_on
    attr_accessor :state

    def initialize(number:, subscription:, amount_cents:, failed_on: nil)
      @number = number
      @subscription = subscription
      @amount_cents = amount_cents
      @failed_on = failed_on
      @state = failed_on ? :past_due : :open
    end

    def mark_paid!
      self.state = :paid
    end
  end
end
RUBY

cat > lib/billing/dunning.rb <<'RUBY'
require "date"
require_relative "../mailers/dunning_mailer"

module Billing
  class Dunning
    RETRY_SCHEDULE_DAYS = [2, 5, 11].freeze
    SUSPEND_AFTER_DAYS = 21

    def initialize(gateway:, today: Date.today)
      @gateway = gateway
      @today = today
    end

    def run(invoices)
      invoices.select { |invoice| invoice.state == :past_due }.each { |invoice| step(invoice) }
    end

    private

    def step(invoice)
      days_late = (@today - invoice.failed_on).to_i

      if days_late >= SUSPEND_AFTER_DAYS
        invoice.subscription.suspend!
        DunningMailer.deliver(:suspended, invoice)
      elsif RETRY_SCHEDULE_DAYS.include?(days_late)
        if @gateway.charge(invoice.amount_cents)
          invoice.mark_paid!
          DunningMailer.deliver(:recovered, invoice)
        elsif days_late == RETRY_SCHEDULE_DAYS.last
          DunningMailer.deliver(:final_notice, invoice)
        else
          DunningMailer.deliver(:payment_failed, invoice)
        end
      end
    end
  end
end
RUBY

cat > lib/mailers/dunning_mailer.rb <<'RUBY'
module DunningMailer
  SUBJECTS = {
    payment_failed: "Your card was declined. We'll try again soon.",
    final_notice: "Last try failed. Update your card within 10 days to keep access.",
    suspended: "Your account is paused until you update your card.",
    recovered: "Payment received. Thanks!"
  }.freeze

  def self.deliver(template, invoice)
    puts "To #{invoice.subscription.customer}: #{SUBJECTS.fetch(template)} (invoice ##{invoice.number})"
  end
end
RUBY

cat > db/seeds.rb <<'RUBY'
require "date"
require_relative "../lib/billing/subscription"
require_relative "../lib/billing/invoice"

PINECREST = Billing::Subscription.new(customer: "Pinecrest Bakery", plan: "Team", monthly_cents: 4900)

INVOICES = [
  Billing::Invoice.new(number: 7302, subscription: PINECREST, amount_cents: 4900, failed_on: Date.new(2026, 3, 1))
].freeze
RUBY

cat > bin/nightly_billing <<'RUBY'
#!/usr/bin/env ruby
# Cron runs this once a day at 06:00 UTC.
require_relative "../db/seeds"
require_relative "../lib/billing/dunning"

class DecliningGateway
  def charge(_cents)
    false
  end
end

Billing::Dunning.new(gateway: DecliningGateway.new, today: Date.parse(ARGV.fetch(0, Date.today.to_s))).run(INVOICES)
RUBY
chmod +x bin/nightly_billing

cat > README.md <<'MD'
# Pinecrest Billing

Charges subscribers monthly. Run `bin/nightly_billing YYYY-MM-DD` to process a day.
MD
