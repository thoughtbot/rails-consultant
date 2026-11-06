#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q "$@"; }

mkdir -p app/models app/mailers app/views/order_mailer app/controllers/admin db/migrate test/models

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_09_01_120000) do
  create_table "orders", force: :cascade do |t|
    t.string "email", null: false
    t.text "notes"
    t.timestamps
  end
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  validates :email, presence: true
end
RUBY

commit -m "Add orders"

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    mail to: order.email, subject: "Your order ##{order.id}"
  end
end
RUBY

cat > app/controllers/admin/orders_controller.rb <<'RUBY'
class Admin::OrdersController < Admin::BaseController
  def update
    order = Order.find(params[:id])
    order.update!(params.require(:order).permit(:notes))
    redirect_to admin_order_path(order)
  end
end
RUBY

commit -m "Email a receipt when an order is placed"

git remote add origin git@github.com:acme/shop.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

git checkout -q -b shipping-emails

cat > db/migrate/20261028100000_add_shipped_at_to_orders.rb <<'RUBY'
class AddShippedAtToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :shipped_at, :datetime
  end
end
RUBY

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_10_28_100000) do
  create_table "orders", force: :cascade do |t|
    t.string "email", null: false
    t.text "notes"
    t.datetime "shipped_at"
    t.timestamps
  end
end
RUBY

commit -m "Add shipped_at to orders" \
  -m "Support checks the courier site by hand to see if an order has left
the warehouse. Recording it on the order is the first step to telling
the customer ourselves."

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  validates :email, presence: true

  after_save :send_shipped_email, if: -> { shipped_at.present? }

  def ship!
    update!(shipped_at: Time.current)
  end

  private

  def send_shipped_email
    OrderMailer.shipped(self).deliver_later
  end
end
RUBY

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    mail to: order.email, subject: "Your order ##{order.id}"
  end

  def shipped(order)
    @order = order
    mail to: order.email, subject: "Order ##{order.id} is on its way"
  end
end
RUBY

cat > app/views/order_mailer/shipped.text.erb <<'ERB'
Good news: order #<%= @order.id %> shipped on <%= @order.shipped_at.to_date %>.
ERB

commit -m "Email the customer when their order ships" \
  -m "Most \"where's my order?\" emails to support arrive the day after an
order ships. Telling the customer as it ships should cut those down."

cat > test/models/order_test.rb <<'RUBY'
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "shipping an order emails the customer" do
    order = Order.create!(email: "sam@example.com")

    assert_enqueued_email_with OrderMailer, :shipped, args: [order] do
      order.ship!
    end
  end
end
RUBY

commit -m "Test the shipped email"
