#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q -m "$1"; }

mkdir -p app/models app/controllers app/mailers db

cat > README.md <<'MD'
# Shop

A Rails 8 shop. Run the tests with `bin/rails test`.
MD

commit "Set up the shop"

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_09_01_100000) do
  create_table "customers", force: :cascade do |t|
    t.string "email"
    t.timestamps
  end

  create_table "orders", force: :cascade do |t|
    t.references "customer", null: false
    t.integer "total_cents"
    t.timestamps
  end

  create_table "line_items", force: :cascade do |t|
    t.references "order", null: false
    t.string "product_name"
    t.integer "price_cents"
  end
end
RUBY

cat > app/models/customer.rb <<'RUBY'
class Customer < ApplicationRecord
  has_many :orders
end
RUBY

cat > app/models/line_item.rb <<'RUBY'
class LineItem < ApplicationRecord
  belongs_to :order
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  belongs_to :customer
  has_many :line_items
  accepts_nested_attributes_for :line_items

  before_save :compute_total

  private

  def compute_total
    self.total_cents = line_items.sum(&:price_cents)
  end
end
RUBY

cat > app/controllers/orders_controller.rb <<'RUBY'
class OrdersController < ApplicationController
  def create
    @order = current_customer.orders.build(order_params)

    if @order.save
      redirect_to @order, notice: "Thanks for your order!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(line_items_attributes: [:product_name, :price_cents])
  end
end
RUBY

commit "Add orders"

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    mail to: order.customer.email, subject: "Your receipt for order ##{order.id}"
  end
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  belongs_to :customer
  has_many :line_items
  accepts_nested_attributes_for :line_items

  before_save :compute_total
  after_commit :send_receipt, on: :create

  private

  def compute_total
    self.total_cents = line_items.sum(&:price_cents)
  end

  def send_receipt
    OrderMailer.receipt(self).deliver_later
  end
end
RUBY

commit "Email a receipt for each order"
