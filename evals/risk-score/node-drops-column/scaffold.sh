#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q "$@"; }

mkdir -p src migrations test

cat > package.json <<'JSON'
{
  "name": "store",
  "private": true,
  "dependencies": {
    "express": "^4.21.0",
    "knex": "^3.1.0"
  }
}
JSON

cat > migrations/20260901120000_create_orders.js <<'JS'
exports.up = (knex) =>
  knex.schema.createTable("orders", (table) => {
    table.increments("id");
    table.string("email").notNullable();
    table.string("legacy_status");
    table.timestamps(true, true);
  });

exports.down = (knex) => knex.schema.dropTable("orders");
JS

cat > src/orders.js <<'JS'
const db = require("./db");

exports.legacyOpen = () => db("orders").where({ legacy_status: "open" });
exports.find = (id) => db("orders").where({ id }).first();
JS

cat > test/orders.test.js <<'JS'
const orders = require("../src/orders");

test("finds an order", async () => {
  expect(await orders.find(1)).toBeDefined();
});
JS

commit -m "Initial commit"

git remote add origin git@github.com:acme/store.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

git checkout -q -b drop-legacy-status

cat > migrations/20261103090000_drop_legacy_status.js <<'JS'
exports.up = (knex) =>
  knex.schema.alterTable("orders", (table) => {
    table.dropColumn("legacy_status");
  });

exports.down = (knex) =>
  knex.schema.alterTable("orders", (table) => {
    table.string("legacy_status");
  });
JS

cat > src/orders.js <<'JS'
const db = require("./db");

exports.find = (id) => db("orders").where({ id }).first();
JS

sed -i.bak 's/"knex": "^3.1.0"/"knex": "^3.2.0"/' package.json && rm package.json.bak

commit -m "Drop the legacy order status"
