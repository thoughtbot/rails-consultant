#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

mkdir -p app/models app/controllers app/views/orders config db/migrate lib/tasks

cat > Gemfile <<'RUBY'
source "https://rubygems.org"

gem "rails", "~> 7.1"
gem "pg"
RUBY

cat > config/application.rb <<'RUBY'
require_relative "boot"
require "rails/all"

module Shop
  class Application < Rails::Application
    config.load_defaults 7.1
  end
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy
end
RUBY

cat > app/models/line_item.rb <<'RUBY'
class LineItem < ApplicationRecord
  belongs_to :order
end
RUBY

cat > app/controllers/orders_controller.rb <<'RUBY'
class OrdersController < ApplicationController
  def index
    @orders = Order.order(created_at: :desc).limit(100)
  end
end
RUBY

cat > app/views/orders/index.html.erb <<'ERB'
<h1>Orders</h1>
<table>
  <% @orders.each do |order| %>
    <tr>
      <td><%= order.id %></td>
      <td><%= number_to_currency(order.line_items.sum(:price_cents) / 100.0) %></td>
    </tr>
  <% end %>
</table>
ERB

cat > lib/tasks/import.rake <<'RUBY'
namespace :import do
  desc "Nightly import of line items from the warehouse CSV"
  task line_items: :environment do
    require "csv"
    rows = CSV.read(ENV.fetch("CSV_PATH"), headers: true).map(&:to_h)
    LineItem.insert_all(rows)
  end
end
RUBY

git add -A
git commit -q -m "Initial app"

git checkout -q -b order-total-column

cat > db/migrate/20261020120000_add_total_cents_to_orders.rb <<'RUBY'
class AddTotalCentsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :total_cents, :integer, null: false, default: 0
  end
end
RUBY

cat > app/models/line_item.rb <<'RUBY'
class LineItem < ApplicationRecord
  belongs_to :order

  after_save :refresh_order_total
  after_destroy :refresh_order_total

  private

  def refresh_order_total
    order.update!(total_cents: order.line_items.sum(:price_cents))
  end
end
RUBY

git add -A
git commit -q -F - <<'MSG'
Store order totals in a column

The orders index summed line_items once per row, one query per order.
Store the sum in orders.total_cents and keep it current from LineItem
callbacks.

Tried counter_cache first. It only keeps a row count, so it can't hold
a sum of prices.

Risk: total_cents goes stale whenever line items change without
callbacks: update_column, update_all, or the nightly import task, which
writes line_items with insert_all.
MSG

cat > db/migrate/20261020120100_backfill_order_totals.rb <<'RUBY'
class BackfillOrderTotals < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE orders
      SET total_cents = (
        SELECT COALESCE(SUM(price_cents), 0)
        FROM line_items
        WHERE line_items.order_id = orders.id
      )
    SQL
  end

  def down
  end
end
RUBY

git add -A
git commit -q -F - <<'MSG'
Backfill order totals

One UPDATE inside the migration. Fine at our ~40k orders, but it holds
a lock on orders for the whole statement, so a much bigger table would
need a batched job instead.
MSG

cat > app/views/orders/index.html.erb <<'ERB'
<h1>Orders</h1>
<table>
  <% @orders.each do |order| %>
    <tr>
      <td><%= order.id %></td>
      <td><%= number_to_currency(order.total_cents / 100.0) %></td>
    </tr>
  <% end %>
</table>
ERB

git add -A
git commit -q -m "Read order totals from the column in the index"
