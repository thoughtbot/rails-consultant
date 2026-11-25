#!/usr/bin/env bash
# Builds a tiny Ruby app that receives payment webhooks and skips repeats. No gems, no network.
set -euo pipefail

mkdir -p lib/webhooks test/fixtures

cat > lib/webhooks/seen_store.rb <<'RUBY'
module Webhooks
  class SeenStore
    def initialize(clock: -> { Time.now.to_i })
      @clock = clock
      @expires_at = {}
    end

    def seen?(event_id)
      expiry = @expires_at[event_id]
      !expiry.nil? && expiry > @clock.call
    end

    def remember(event_id, ttl:)
      @expires_at[event_id] = @clock.call + ttl
    end
  end
end
RUBY

cat > lib/webhooks/processor.rb <<'RUBY'
require_relative "seen_store"

module Webhooks
  class Processor
    SEEN_TTL_SECONDS = 72 * 60 * 60

    def initialize(store:, handlers:)
      @store = store
      @handlers = handlers
    end

    def call(event)
      return :duplicate if @store.seen?(event.fetch("id"))

      handler = @handlers[event.fetch("type")]
      return :ignored unless handler

      handler.call(event)
      @store.remember(event.fetch("id"), ttl: SEEN_TTL_SECONDS)
      :processed
    end
  end
end
RUBY

cat > lib/webhooks/handlers.rb <<'RUBY'
module Webhooks
  HANDLERS = {
    "invoice.paid" => ->(event) { puts "Marking invoice #{event.dig("data", "invoice")} paid" },
    "charge.refunded" => ->(event) { puts "Refunding #{event.dig("data", "amount_cents")} cents" }
  }.freeze
end
RUBY

cat > test/fixtures/events.json <<'JSON'
[
  {"id": "evt_3QmX81", "type": "invoice.paid", "data": {"invoice": 7302}},
  {"id": "evt_3QmX81", "type": "invoice.paid", "data": {"invoice": 7302}},
  {"id": "evt_3QmY04", "type": "customer.updated", "data": {}}
]
JSON

cat > README.md <<'MD'
# Pinecrest Webhooks

Receives payment events from the payment provider. The provider resends an
event until we answer, for up to 3 days, so the same event can arrive more
than once.
MD
