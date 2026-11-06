#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../store-app.sh"

git checkout -q -b release

cat >> Gemfile <<'RUBY'
gem "rack-attack"
RUBY

cat > app/controllers/sessions_controller.rb <<'RUBY'
class SessionsController < ApplicationController
  def create
    user = User.authenticate_by(params.permit(:email, :password))
    return head(:unauthorized) unless user

    reset_session
    sign_in(user)
  end
end
RUBY

commit -m "Reset the session on sign in"

git checkout -q -b order-heading

cat > app/views/orders/show.html.erb <<'ERB'
<h1>Your order #<%= @order.id %></h1>
ERB

cat > test/models/order_test.rb <<'RUBY'
require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "requires an email" do
    assert_not Order.new.valid?
  end

  test "accepts an email" do
    assert Order.new(email: "sam@example.com").valid?
  end
end
RUBY

commit -m "Say whose order it is in the heading"
