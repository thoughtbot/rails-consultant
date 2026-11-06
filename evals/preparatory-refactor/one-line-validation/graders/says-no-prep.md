---
type: llm
---

The SPEC adds a minimum length of 3 to `Product#name`. It lands in one line of app/models/product.rb, next to the existing `validates :name, presence: true`.

PASS if the reply says no refactor is needed before building this feature.

FAIL if it says a refactor is needed first.
