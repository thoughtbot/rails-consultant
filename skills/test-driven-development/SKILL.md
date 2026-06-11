---
name: test-driven-development
description: Strict red-green-refactor TDD workflow for implementing features, fixing bugs, or changing behavior in Rails applications. Enforces the discipline of writing a failing test before any production code. Use whenever you want to implement with TDD — whether a new feature, a bugfix, a refactor, or any behavior change.
argument-hint: "[feature, bug, or behavior to implement]"
disable-model-invocation: true
---

# Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over.

**No exceptions:**

- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete

Implement fresh from tests. Period.

## Outside-In Development

Start every feature with a high-level test that describes behavior from the user's perspective. Run it, read the failure, and let that failure dictate your next move. As failures push you down the stack, write a new failing test at each layer you drop into — never write code for a layer without a failing test at that layer demanding it.

Read `examples/outside-in-testing.md` for a walkthrough of the philosophy and `examples/testing-pyramid.md` for how test types combine into an optimal suite.

### One Change, One Run

After every change — writing a test, adding a route, creating a file, implementing a method — run the affected test immediately:

```bash
bundle exec rspec spec/features/guest_searches_for_items_spec.rb
```

The failure message is your instruction for what to do next. Don't batch changes and don't guess ahead: one change, one run, read the failure, decide. If you made two changes before running, you no longer know which one the test is reacting to.

### Drop Down by Writing the Next Failing Test

A failure rarely means "write this exact line." It usually means "the layer below isn't there yet." When the active test's failure points to a layer that has behavior of its own — a controller action, an endpoint, a model method — **drop down and write a failing test at that layer before building it.**

Think of it as a stack of failing tests:

- The **active** test is the one whose failure you're reading right now.
- Its failure points to a missing lower layer → write a new failing test at that layer. It becomes the active test.
- Drive that test with Red-Green-Refactor. If _it_ forces you down another level, push another failing test.
- When the active test goes green, pop it: rerun the test one layer up. Its next failure drives the next move.

Drop to whichever layer the failure names — not always one rung at a time. Continue until the top-level feature spec is green with nothing left on the stack.

The ladder of test types, top to bottom:

| When the failure points to…                                         | Write this failing test      |
| ------------------------------------------------------------------- | ---------------------------- |
| End-to-end behavior from the user's perspective                     | Feature / system spec        |
| A controller action, response, status, or redirect                  | Request (or controller) spec |
| Logic in a model, service object, query, calculation, or validation | Model / unit spec            |

Feature and request specs are integration tests: real database records, no mocks — except external services (use webmock or fakes), so the suite runs offline. Unit specs isolate the object under test: mock collaborators aggressively, because the goal is to prove _this_ object, not its collaborators. Difficulty testing two objects in isolation signals too-tight coupling.

### Build Directly Only for Inert Glue

A few things have no behavior of their own, so they get no test of their own — but you still add them only because a failing test one layer up demanded them:

- The route line (a request spec failing with `No route matches` drives it)
- An empty class or module to clear a `NameError`
- Trivial markup a feature spec's content expectation already covers

Everything with behavior gets its own failing test first. When in doubt, drop down and write the test.

The testing pyramid: many unit tests at the bottom, fewer request specs in the middle, a few feature specs at the top. Unit tests are fast and precise; feature tests prove the system works end-to-end. Each plays to its strengths.

## Red-Green-Refactor

The cycle every test follows — feature spec, request spec, and model spec alike. Each failing test on the stack runs this loop; a test going green is what lets you pop back up to the layer above.

```dot
digraph tdd_cycle {
    rankdir=LR;
    red [label="RED\nWrite failing test", shape=box, style=filled, fillcolor="#ffcccc"];
    verify_red [label="Verify fails\ncorrectly", shape=diamond];
    green [label="GREEN\nMinimal code", shape=box, style=filled, fillcolor="#ccffcc"];
    verify_green [label="Verify passes\nAll green", shape=diamond];
    refactor [label="REFACTOR\nClean up", shape=box, style=filled, fillcolor="#ccccff"];
    next [label="Next", shape=ellipse];

    red -> verify_red;
    verify_red -> green [label="yes"];
    verify_red -> red [label="wrong\nfailure"];
    green -> verify_green;
    verify_green -> refactor [label="yes"];
    verify_green -> green [label="no"];
    refactor -> verify_green [label="stay\ngreen"];
    verify_green -> next;
    next -> red;
}
```

### RED — Write Failing Test

Write one minimal test showing what should happen.

<Good>

```ruby
RSpec.describe Item, ".search" do
  it "filters items by the search term" do
    desired_item = create(:item, name: "Widget")
    _other_item = create(:item, name: "Gadget")

    expect(Item.search("Widget")).to eq [desired_item]
  end
end
```

Clear name, tests real behavior, one thing.

</Good>

<Bad>

```ruby
it "search works" do
  relation = spy("relation")
  allow(Item).to receive(:where).and_return(relation)

  Item.search("Widget")

  expect(Item).to have_received(:where).with(name: "Widget")
end
```

Vague name, tests spy interactions not real behavior, proves nothing about whether search actually returns the right items.

</Bad>

**Requirements:**

- One behavior
- Clear name
- Feature specs: real records, no mocks (except external services)
- Unit tests: mock collaborators, test the object in isolation

### Verify RED — Watch It Fail

**MANDATORY. Never skip.**

```bash
bundle exec rspec spec/models/item_spec.rb
```

Confirm:

- Test fails (not errors)
- Failure message is expected
- Fails because feature missing (not typos)

**Test passes?** You're testing existing behavior. Fix test.

**Test errors?** Fix error, re-run until it fails correctly.

### GREEN — Minimal Code

Write simplest code to pass the test.

<Good>

```ruby
class Item < ApplicationRecord
  def self.search(term)
    where(name: term)
  end
end
```

Just enough to pass.

</Good>

<Bad>

```ruby
class Item < ApplicationRecord
  def self.search(term, fuzzy: false, limit: nil, scope: :all)
    # YAGNI — the test asked for name filtering, not a search framework
  end
end
```

Over-engineered.

</Bad>

Don't add features, refactor other code, or "improve" beyond the test.

### Verify GREEN — Watch It Pass

**MANDATORY.**

```bash
bundle exec rspec spec/models/item_spec.rb
```

Confirm:

- Test passes
- Other tests still pass
- Output pristine (no errors, warnings)

**Test fails?** Fix code, not test.

**Other tests fail?** Fix now.

### REFACTOR — Clean Up

After green only:

- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

### Repeat

Pop the stack. Rerun the test one layer up and read its next failure — it drives the next move: build inert glue, or push a new failing test for the next layer down. Keep going until the top-level feature spec is green and the stack is empty.

## Good Tests

| Quality          | Good                                | Bad                                              |
| ---------------- | ----------------------------------- | ------------------------------------------------ |
| **Minimal**      | One thing. "and" in name? Split it. | `it "validates email and domain and whitespace"` |
| **Clear**        | Name describes behavior             | `it "test1"`                                     |
| **Shows intent** | Demonstrates desired API            | Obscures what code should do                     |

## Why Order Matters

**"I'll write tests after to verify it works"**

Tests written after code pass immediately. Passing immediately proves nothing:

- Might test wrong thing
- Might test implementation, not behavior
- Might miss edge cases you forgot
- You never saw it catch the bug

Test-first forces you to see the test fail, proving it actually tests something.

**"I already manually tested all the edge cases"**

Manual testing is ad-hoc. You think you tested everything but:

- No record of what you tested
- Can't re-run when code changes
- Easy to forget cases under pressure
- "It worked when I tried it" ≠ comprehensive

Automated tests are systematic. They run the same way every time.

**"Deleting X hours of work is wasteful"**

Sunk cost fallacy. The time is already gone. Your choice now:

- Delete and rewrite with TDD (X more hours, high confidence)
- Keep it and add tests after (30 min, low confidence, likely bugs)

The "waste" is keeping code you can't trust. Working code without real tests is technical debt.

**"TDD is dogmatic, being pragmatic means adapting"**

TDD IS pragmatic:

- Finds bugs before commit (faster than debugging after)
- Prevents regressions (tests catch breaks immediately)
- Documents behavior (tests show how to use code)
- Enables refactoring (change freely, tests catch breaks)

"Pragmatic" shortcuts = debugging in production = slower.

**"Tests after achieve the same goals — it's spirit not ritual"**

No. Tests-after answer "What does this do?" Tests-first answer "What should this do?"

Tests-after are biased by your implementation. You test what you built, not what's required. You verify remembered edge cases, not discovered ones.

Tests-first force edge case discovery before implementing. Tests-after verify you remembered everything (you didn't).

30 minutes of tests after ≠ TDD. You get coverage, lose proof tests work.

## Common Rationalizations

| Excuse                                  | Reality                                                                  |
| --------------------------------------- | ------------------------------------------------------------------------ |
| "Too simple to test"                    | Simple code breaks. Test takes 30 seconds.                               |
| "Controller's just wiring, skip a spec" | Wiring has behavior — routing, params, response. Write the request spec. |
| "I'll run the test once at the end"     | You won't know which change caused which failure. One change, one run.   |
| "I'll test after"                       | Tests passing immediately prove nothing.                                 |
| "Tests after achieve same goals"        | Tests-after = "what does this do?" Tests-first = "what should this do?"  |
| "Already manually tested"               | Ad-hoc ≠ systematic. No record, can't re-run.                            |
| "Deleting X hours is wasteful"          | Sunk cost fallacy. Keeping unverified code is technical debt.            |
| "Keep as reference, write tests first"  | You'll adapt it. That's testing after. Delete means delete.              |
| "Need to explore first"                 | Fine. Throw away exploration, start with TDD.                            |
| "Test hard = design unclear"            | Listen to test. Hard to test = hard to use.                              |
| "TDD will slow me down"                 | TDD faster than debugging. Pragmatic = test-first.                       |
| "Manual test faster"                    | Manual doesn't prove edge cases. You'll re-test every change.            |
| "Existing code has no tests"            | You're improving it. Add tests for existing code.                        |

## Red Flags — STOP and Start Over

- Code before test
- Built a controller, model method, or service without a failing test at that layer
- Made several changes, then ran the test once
- Test after implementation
- Test passes immediately
- Can't explain why test failed
- Tests added "later"
- Rationalizing "just this once"
- "I already manually tested it"
- "Tests after achieve the same purpose"
- "It's about spirit not ritual"
- "Keep as reference" or "adapt existing code"
- "Already spent X hours, deleting is wasteful"
- "TDD is dogmatic, I'm being pragmatic"
- "This is different because..."

**All of these mean: Delete code. Start over with TDD.**

## Example: Feature (Outside-In)

**Story:** As a guest, I can search for items so I can find what I want.

**Top of the stack — feature spec**

```ruby
# spec/features/guest_searches_for_items_spec.rb
feature "Guest searches for items" do
  scenario "by name" do
    create(:item, name: "Widget")

    visit root_path
    fill_in "Search", with: "Widget"
    click_on "Search"

    expect(page).to have_content("Widget")
  end
end
```

Run it. The failure points at the items index — a controller-layer concern. Don't build an empty action the feature spec merely covers; drop down and write a failing **request spec.**

**Drop down — request spec**

```ruby
# spec/requests/items_spec.rb
RSpec.describe "Items", type: :request do
  it "renders items matching the search term" do
    create(:item, name: "Widget")

    get items_path, params: { search: "Widget" }

    expect(response.body).to include("Widget")
  end
end
```

Run it — one change, one run, each time:

- `No route matches` → add the route (inert glue). Run again.
- `uninitialized constant ItemsController` → create the controller and an empty `index`. Run again.
- Body is missing "Widget" → the action needs `Item.search`, which is logic. Drop down again and write a failing **model spec.**

**Drop down — model spec**

```ruby
# spec/models/item_spec.rb
RSpec.describe Item, ".search" do
  it "filters items by name" do
    desired = create(:item, name: "Widget")
    _other = create(:item, name: "Gadget")

    expect(Item.search("Widget")).to eq [desired]
  end
end
```

Verify RED. Implement `Item.search`. Verify GREEN — pop the model spec. Rerun the request spec; wire the action and view until it's green, then pop it. Rerun the feature spec and drive the remaining UI pieces the same way until it's green and the stack is empty.

## Example: Bug Fix

**Bug:** Empty email accepted

Start with a feature spec reproducing the bug from the user's perspective. Registration already exists, so the failure points straight at the model's missing validation — drop directly to a model spec rather than through the request layer. Drop to the layer the failure names.

**Top of the stack — feature spec**

```ruby
# spec/features/guest_registers_spec.rb
feature "Guest registers" do
  scenario "with blank email" do
    visit new_registration_path
    fill_in "Email", with: ""
    click_on "Register"

    expect(page).to have_content("Email can't be blank")
  end
end
```

**Drop down — model spec**

```ruby
# spec/models/user_spec.rb
RSpec.describe User do
  it "rejects empty email" do
    user = User.new(email: "")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end
end
```

**GREEN**

```ruby
class User < ApplicationRecord
  validates :email, presence: true
end
```

Model spec passes — pop it. Rerun the feature spec; it's green. Done.

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Ran the affected test after every change — never batched two changes before running
- [ ] Each layer dropped into (controller, model, service) got its own failing test first
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? You skipped TDD. Start over.

## When Stuck

| Problem                | Solution                                                             |
| ---------------------- | -------------------------------------------------------------------- |
| Don't know how to test | Write wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated   | Design too complicated. Simplify interface.                          |
| Must mock everything   | Code too coupled. Use dependency injection.                          |
| Test setup huge        | Extract helpers. Still complex? Simplify design.                     |

## Debugging Integration

Bug found? Write failing test reproducing it. Follow TDD cycle. Test proves fix and prevents regression.

Never fix bugs without a test.

## Testing Anti-Patterns

When adding mocks or test utilities, read `references/testing-anti-patterns.md` to avoid common pitfalls:

- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

## Final Rule

```
Production code → test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.
