#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q -m "$1"; }

mkdir -p lib test

cat > README.md <<'MD'
# Billing

Plain Ruby and Minitest, no gems. One test file: `ruby -Ilib -Itest test/invoice_test.rb`. Everything: `rake test`.
MD

cat > Rakefile <<'RUBY'
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib" << "test"
  t.test_files = FileList["test/*_test.rb"]
end
RUBY

cat > lib/plan.rb <<'RUBY'
class Plan
  attr_reader :name, :price_cents

  def initialize(name:, price_cents:)
    @name = name
    @price_cents = price_cents
  end

  def free?
    price_cents.zero?
  end
end
RUBY

cat > test/plan_test.rb <<'RUBY'
require "minitest/autorun"
require "plan"

class PlanTest < Minitest::Test
  def test_is_free_when_it_costs_nothing
    plan = Plan.new(name: "Hobby", price_cents: 0)

    free = plan.free?

    assert free
  end
end
RUBY

commit "Add plans"

cat > lib/invoice.rb <<'RUBY'
class Invoice
  attr_reader :plan, :issued_on, :paid_on

  def initialize(plan:, issued_on:)
    @plan = plan
    @issued_on = issued_on
  end

  def amount_cents
    plan.price_cents
  end

  def pay(on)
    @paid_on = on
  end

  def paid?
    !paid_on.nil?
  end
end
RUBY

cat > test/invoice_test.rb <<'RUBY'
require "minitest/autorun"
require "date"
require "plan"
require "invoice"

class InvoiceTest < Minitest::Test
  def test_amount_is_the_plan_price
    plan = Plan.new(name: "Pro", price_cents: 1200)

    invoice = Invoice.new(plan: plan, issued_on: Date.new(2026, 3, 1))

    assert_equal 1200, invoice.amount_cents
  end

  def test_is_paid_once_paid
    invoice = Invoice.new(plan: Plan.new(name: "Pro", price_cents: 1200), issued_on: Date.new(2026, 3, 1))

    invoice.pay(Date.new(2026, 3, 5))

    assert invoice.paid?
  end
end
RUBY

commit "Add invoices"
