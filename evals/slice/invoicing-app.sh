#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q -m "$1"; }

mkdir -p app/models app/controllers app/views/customers app/views/invoices config db test/controllers

cat > README.md <<'MD'
# Invoicing

A Rails 8 app for customers and the invoices we send them. Run the tests with `bin/rails test`.
MD

commit "Set up the app"

cat > app/models/customer.rb <<'RUBY'
require "csv"

class Customer < ApplicationRecord
  has_many :invoices

  def self.to_csv(customers)
    CSV.generate do |csv|
      csv << ["Name", "Email"]
      customers.each { |customer| csv << [customer.name, customer.email] }
    end
  end
end
RUBY

cat > app/controllers/customers_controller.rb <<'RUBY'
class CustomersController < ApplicationController
  def index
    @customers = Customer.order(:name)

    respond_to do |format|
      format.html
      format.csv { send_data Customer.to_csv(@customers), filename: "customers.csv" }
    end
  end
end
RUBY

cat > app/views/customers/index.html.erb <<'ERB'
<h1>Customers</h1>
<% @customers.each do |customer| %>
  <p><%= customer.name %> (<%= customer.email %>)</p>
<% end %>
<%= link_to "Download CSV", customers_path(format: :csv) %>
ERB

cat > config/routes.rb <<'RUBY'
Rails.application.routes.draw do
  resources :customers, only: :index
end
RUBY

cat > test/controllers/customers_controller_test.rb <<'RUBY'
require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  test "downloads customers as CSV" do
    Customer.create!(name: "Acme", email: "ap@acme.example")

    get customers_path(format: :csv)

    assert_equal "Name,Email\nAcme,ap@acme.example\n", response.body
  end
end
RUBY

commit "Add customers, with CSV export"

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_03_04_100000) do
  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.timestamps
  end

  create_table "invoices", force: :cascade do |t|
    t.references "customer", null: false
    t.string "number"
    t.integer "amount_cents"
    t.date "issued_on"
    t.date "due_on"
    t.date "paid_on"
    t.timestamps
  end
end
RUBY

cat > app/models/invoice.rb <<'RUBY'
class Invoice < ApplicationRecord
  belongs_to :customer

  def paid?
    paid_on.present?
  end
end
RUBY

cat > app/controllers/invoices_controller.rb <<'RUBY'
class InvoicesController < ApplicationController
  def index
    @invoices = Invoice.includes(:customer).order(issued_on: :desc)
  end
end
RUBY

cat > app/views/invoices/index.html.erb <<'ERB'
<h1>Invoices</h1>
<table>
  <% @invoices.each do |invoice| %>
    <tr>
      <td><%= invoice.number %></td>
      <td><%= invoice.customer.name %></td>
      <td><%= number_to_currency(invoice.amount_cents / 100.0) %></td>
      <td><%= invoice.due_on %></td>
      <td><%= invoice.paid? ? "Paid" : "Unpaid" %></td>
    </tr>
  <% end %>
</table>
ERB

cat > config/routes.rb <<'RUBY'
Rails.application.routes.draw do
  resources :customers, only: :index
  resources :invoices, only: :index
end
RUBY

commit "Add invoices"
