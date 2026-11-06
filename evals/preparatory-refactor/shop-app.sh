#!/usr/bin/env bash
# Builds a Rails-shaped shop whose order total math is copied into Order, OrderMailer and InvoicePdf. No gems, nothing runs.
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

day=0
commit() {
  day=$((day + 1))
  local stamp
  stamp="2026-03-$(printf '%02d' "$day")T10:00:00Z"
  git add -A
  GIT_AUTHOR_DATE="$stamp" GIT_COMMITTER_DATE="$stamp" git commit -q -m "$1"
}

mkdir -p app/models app/controllers app/mailers app/views/order_mailer app/pdfs config db test/models test/mailers test/pdfs

cat > Gemfile <<'RUBY'
source "https://rubygems.org"

gem "rails", "~> 8.0"
gem "sqlite3"
RUBY

cat > config/application.rb <<'RUBY'
require_relative "boot"
require "rails/all"

module Shop
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_paths << Rails.root.join("app/pdfs")
  end
end
RUBY

cat > app/models/application_record.rb <<'RUBY'
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
RUBY

cat > app/controllers/application_controller.rb <<'RUBY'
class ApplicationController < ActionController::Base
end
RUBY

cat > app/mailers/application_mailer.rb <<'RUBY'
class ApplicationMailer < ActionMailer::Base
  default from: "orders@shop.example"
end
RUBY

cat > README.md <<'MD'
# Shop

A small storefront. Run the tests with `bin/rails test`.
MD

commit "Set up the shop app"

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_03_02_100000) do
  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents"
    t.timestamps
  end
end
RUBY

cat > app/models/product.rb <<'RUBY'
class Product < ApplicationRecord
end
RUBY

cat > test/models/product_test.rb <<'RUBY'
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "saves with a name and price" do
    assert Product.new(name: "Mug", price_cents: 1250).save
  end
end
RUBY

commit "Add products"

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_03_03_100000) do
  create_table "customers", force: :cascade do |t|
    t.string "email", null: false
    t.timestamps
  end

  create_table "line_items", force: :cascade do |t|
    t.references "order", null: false
    t.references "product", null: false
    t.integer "quantity", null: false, default: 1
    t.integer "unit_price_cents", null: false
    t.timestamps
  end

  create_table "orders", force: :cascade do |t|
    t.references "customer", null: false
    t.string "status", null: false, default: "cart"
    t.timestamps
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "price_cents"
    t.timestamps
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
  belongs_to :product
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  belongs_to :customer
  has_many :line_items, dependent: :destroy

  def total_cents
    line_items.sum { |item| item.unit_price_cents * item.quantity }
  end
end
RUBY

cat > app/controllers/checkouts_controller.rb <<'RUBY'
class CheckoutsController < ApplicationController
  def create
    order = Order.find(params[:order_id])
    PaymentGateway.charge(order.customer, order.total_cents)
    order.update!(status: "paid")
    redirect_to order_path(order)
  end
end
RUBY

cat > test/models/order_test.rb <<'RUBY'
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "total is the sum of its line items" do
    order = Order.new
    order.line_items.build(unit_price_cents: 1250, quantity: 2)

    assert_equal 2500, order.total_cents
  end
end
RUBY

commit "Add orders and checkout"

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    @total_cents = order.line_items.sum { |item| item.unit_price_cents * item.quantity }
    mail to: order.customer.email, subject: "Your order ##{order.id}"
  end
end
RUBY

cat > app/views/order_mailer/receipt.text.erb <<'ERB'
Thanks for your order!

Total: <%= number_to_currency(@total_cents / 100.0) %>
ERB

cat > app/controllers/checkouts_controller.rb <<'RUBY'
class CheckoutsController < ApplicationController
  def create
    order = Order.find(params[:order_id])
    PaymentGateway.charge(order.customer, order.total_cents)
    order.update!(status: "paid")
    OrderMailer.receipt(order).deliver_later
    redirect_to order_path(order)
  end
end
RUBY

cat > test/mailers/order_mailer_test.rb <<'RUBY'
require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "receipt shows the order total" do
    order = Order.new(id: 7, customer: Customer.new(email: "ada@example.com"))
    order.line_items.build(unit_price_cents: 1250, quantity: 2)

    assert_includes OrderMailer.receipt(order).body.to_s, "$25.00"
  end
end
RUBY

commit "Email a receipt after checkout"

cat > app/pdfs/invoice_pdf.rb <<'RUBY'
class InvoicePdf
  def initialize(order)
    @order = order
  end

  def lines
    [
      "Invoice for order ##{@order.id}",
      "Total: #{dollars(total_cents)}"
    ]
  end

  private

  def total_cents
    @order.line_items.sum { |item| item.unit_price_cents * item.quantity }
  end

  def dollars(cents)
    format("$%.2f", cents / 100.0)
  end
end
RUBY

cat > test/pdfs/invoice_pdf_test.rb <<'RUBY'
require "test_helper"

class InvoicePdfTest < ActiveSupport::TestCase
  test "lists the order total" do
    order = Order.new(id: 7)
    order.line_items.build(unit_price_cents: 1250, quantity: 2)

    assert_includes InvoicePdf.new(order).lines, "Total: $25.00"
  end
end
RUBY

commit "Add PDF invoices"

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  TAX_RATE = 0.08

  belongs_to :customer
  has_many :line_items, dependent: :destroy

  def total_cents
    subtotal = line_items.sum { |item| item.unit_price_cents * item.quantity }
    tax = (subtotal * TAX_RATE).round
    subtotal + tax
  end
end
RUBY

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    @subtotal_cents = order.line_items.sum { |item| item.unit_price_cents * item.quantity }
    @tax_cents = (@subtotal_cents * Order::TAX_RATE).round
    @total_cents = @subtotal_cents + @tax_cents
    mail to: order.customer.email, subject: "Your order ##{order.id}"
  end
end
RUBY

cat > app/views/order_mailer/receipt.text.erb <<'ERB'
Thanks for your order!

Subtotal: <%= number_to_currency(@subtotal_cents / 100.0) %>
Tax: <%= number_to_currency(@tax_cents / 100.0) %>
Total: <%= number_to_currency(@total_cents / 100.0) %>
ERB

cat > app/pdfs/invoice_pdf.rb <<'RUBY'
class InvoicePdf
  def initialize(order)
    @order = order
  end

  def lines
    [
      "Invoice for order ##{@order.id}",
      "Subtotal: #{dollars(subtotal_cents)}",
      "Tax: #{dollars(tax_cents)}",
      "Total: #{dollars(total_cents)}"
    ]
  end

  private

  def subtotal_cents
    @order.line_items.sum { |item| item.unit_price_cents * item.quantity }
  end

  def tax_cents
    (subtotal_cents * Order::TAX_RATE).round
  end

  def total_cents
    subtotal_cents + tax_cents
  end

  def dollars(cents)
    format("$%.2f", cents / 100.0)
  end
end
RUBY

sed -i.bak 's/2500, order.total_cents/2700, order.total_cents/; s/total is the sum of its line items/total adds 8% tax to the line items/' test/models/order_test.rb
sed -i.bak 's/"\$25.00"/"$27.00"/' test/mailers/order_mailer_test.rb
sed -i.bak 's/"Total: \$25.00"/"Total: $27.00"/' test/pdfs/invoice_pdf_test.rb
rm test/models/order_test.rb.bak test/mailers/order_mailer_test.rb.bak test/pdfs/invoice_pdf_test.rb.bak

commit "Charge 8% sales tax"

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  TAX_RATE = 0.08
  SHIPPING_CENTS = 599
  FREE_SHIPPING_THRESHOLD_CENTS = 5000

  belongs_to :customer
  has_many :line_items, dependent: :destroy

  def total_cents
    subtotal = line_items.sum { |item| item.unit_price_cents * item.quantity }
    tax = (subtotal * TAX_RATE).round
    shipping = subtotal >= FREE_SHIPPING_THRESHOLD_CENTS ? 0 : SHIPPING_CENTS
    subtotal + tax + shipping
  end
end
RUBY

cat > app/mailers/order_mailer.rb <<'RUBY'
class OrderMailer < ApplicationMailer
  def receipt(order)
    @order = order
    @subtotal_cents = order.line_items.sum { |item| item.unit_price_cents * item.quantity }
    @tax_cents = (@subtotal_cents * Order::TAX_RATE).round
    @shipping_cents = @subtotal_cents >= Order::FREE_SHIPPING_THRESHOLD_CENTS ? 0 : Order::SHIPPING_CENTS
    @total_cents = @subtotal_cents + @tax_cents + @shipping_cents
    mail to: order.customer.email, subject: "Your order ##{order.id}"
  end
end
RUBY

cat > app/views/order_mailer/receipt.text.erb <<'ERB'
Thanks for your order!

Subtotal: <%= number_to_currency(@subtotal_cents / 100.0) %>
Tax: <%= number_to_currency(@tax_cents / 100.0) %>
Shipping: <%= @shipping_cents.zero? ? "Free" : number_to_currency(@shipping_cents / 100.0) %>
Total: <%= number_to_currency(@total_cents / 100.0) %>
ERB

cat > app/pdfs/invoice_pdf.rb <<'RUBY'
class InvoicePdf
  def initialize(order)
    @order = order
  end

  def lines
    [
      "Invoice for order ##{@order.id}",
      "Subtotal: #{dollars(subtotal_cents)}",
      "Tax: #{dollars(tax_cents)}",
      "Shipping: #{dollars(shipping_cents)}",
      "Total: #{dollars(total_cents)}"
    ]
  end

  private

  def subtotal_cents
    @order.line_items.sum { |item| item.unit_price_cents * item.quantity }
  end

  def tax_cents
    (subtotal_cents * Order::TAX_RATE).round
  end

  def shipping_cents
    subtotal_cents >= Order::FREE_SHIPPING_THRESHOLD_CENTS ? 0 : Order::SHIPPING_CENTS
  end

  def total_cents
    subtotal_cents + tax_cents + shipping_cents
  end

  def dollars(cents)
    format("$%.2f", cents / 100.0)
  end
end
RUBY

cat > test/models/order_test.rb <<'RUBY'
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "total adds 8% tax and shipping under $50" do
    order = Order.new
    order.line_items.build(unit_price_cents: 1250, quantity: 2)

    assert_equal 3299, order.total_cents
  end

  test "shipping is free at $50 and up" do
    order = Order.new
    order.line_items.build(unit_price_cents: 2500, quantity: 2)

    assert_equal 5400, order.total_cents
  end
end
RUBY

sed -i.bak 's/"\$27.00"/"$32.99"/' test/mailers/order_mailer_test.rb
sed -i.bak 's/"Total: \$27.00"/"Total: $32.99"/' test/pdfs/invoice_pdf_test.rb
rm test/mailers/order_mailer_test.rb.bak test/pdfs/invoice_pdf_test.rb.bak

commit "Free shipping on orders of \$50 or more"

cat > app/models/product.rb <<'RUBY'
class Product < ApplicationRecord
  validates :name, presence: true
end
RUBY

cat > test/models/product_test.rb <<'RUBY'
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "saves with a name and price" do
    assert Product.new(name: "Mug", price_cents: 1250).save
  end

  test "requires a name" do
    assert_not Product.new(name: "", price_cents: 1250).valid?
  end
end
RUBY

commit "Require product names"

cat > app/models/product.rb <<'RUBY'
class Product < ApplicationRecord
  validates :name, presence: true
  validates :price_cents, numericality: { greater_than: 0 }
end
RUBY

cat > test/models/product_test.rb <<'RUBY'
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "saves with a name and price" do
    assert Product.new(name: "Mug", price_cents: 1250).save
  end

  test "requires a name" do
    assert_not Product.new(name: "", price_cents: 1250).valid?
  end

  test "requires a positive price" do
    assert_not Product.new(name: "Mug", price_cents: 0).valid?
  end
end
RUBY

commit "Require a positive product price"
