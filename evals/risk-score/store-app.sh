#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q "$@"; }

mkdir -p app/models app/controllers app/views/orders db test/models

cat > Gemfile <<'RUBY'
source "https://rubygems.org"
gem "rails", "~> 8.0"
RUBY

cat > README.md <<'MD'
# Store

Takes orders and emails reciepts.
MD

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_09_01_120000) do
  create_table "orders", force: :cascade do |t|
    t.string "email", null: false
    t.string "legacy_status"
    t.timestamps
  end
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  validates :email, presence: true

  scope :legacy_open, -> { where(legacy_status: "open") }
end
RUBY

cat > app/controllers/sessions_controller.rb <<'RUBY'
class SessionsController < ApplicationController
  def create
    user = User.authenticate_by(params.permit(:email, :password))
    user ? sign_in(user) : head(:unauthorized)
  end
end
RUBY

cat > app/views/orders/show.html.erb <<'ERB'
<h1>Order #<%= @order.id %></h1>
ERB

cat > test/models/order_test.rb <<'RUBY'
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "requires an email" do
    assert_not Order.new.valid?
  end
end
RUBY

commit -m "Initial commit"

git remote add origin git@github.com:acme/store.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
