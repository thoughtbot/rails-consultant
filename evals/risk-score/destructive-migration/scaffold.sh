#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../store-app.sh"

git checkout -q -b drop-legacy-status

mkdir -p db/migrate
cat > db/migrate/20261103090000_remove_legacy_status_from_orders.rb <<'RUBY'
class RemoveLegacyStatusFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :legacy_status, :string
  end
end
RUBY

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[8.0].define(version: 2026_11_03_090000) do
  create_table "orders", force: :cascade do |t|
    t.string "email", null: false
    t.timestamps
  end
end
RUBY

cat > app/models/order.rb <<'RUBY'
class Order < ApplicationRecord
  validates :email, presence: true
end
RUBY

commit -m "Drop the legacy order status"
