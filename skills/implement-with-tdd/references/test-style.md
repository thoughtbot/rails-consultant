# Writing the test

Read this before the first test. The example is Ruby because the house style is
Ruby; the pattern is the point, and the local idiom always wins.

## Arrange / Act / Assert

Three phases, separated by blank lines, in that order:

```ruby
it "adds the tag to the user" do
  tag = create(:tag)
  user = create(:user, tags: [])

  user.add_tag(tag)

  expect(user.tags).to eq([tag])
end
```

Arrange sets up the world. Act exercises the thing under test, once. Assert
checks the result. One act per test — with two, a failure can't tell you which
one broke.

Two blank lines, always: one before the Act, one before the Assert.

Reading the result often takes a call of its own — a second request, a reload, a
query. Keep it with the Act, and leave the blank line above the assertions:

```ruby
it "shows the flag on the list" do
  expense = create(:expense, description: "Coffee")

  post flag_expense_path(expense), params: { reason: "Duplicate" }
  get expenses_path

  expect(response.body).to include("Coffee Flagged")
end
```

That's still one act — two calls, one behavior, and only one of them could have
broken. Assertions running straight off the last call are how three phases turn
into two, and it's the most common way this gets written wrong.

Nothing that asserts belongs in Arrange. Stub during Arrange, then check the call
happened during Assert.

If a test touches the filesystem, environment variables, or the working
directory, clean up after it. Transactional fixtures cover the database and
nothing else, and leaked state is what makes a suite that only fails in a
certain order.

## Keep the setup in the body

Put the Arrange inside the test, not in shared setup blocks or hoisted lazy
variables. Hoisted setup leaves the body holding only the assertion, so finding
the preconditions means reading the rest of the file.

Tests are the place for concretions, not abstractions. Literal values,
spelled-out setup, no loops or conditionals, and never compute the expected value
with the same logic the code uses — that passes even when both sides are wrong.

Name the test after the behavior and the condition, so a list of failures reads
as prose. Prefer a second flat test with the condition in its name over a nested
context that overrides one variable.

## Which layer

Only the outermost test proves the criterion is real. Everything below it pins
down behavior, and that's where most of your tests end up — the top is slow,
needs the most machinery, and breaks when anything nearby changes. Inverted, that
shape is Fowler's ice-cream cone, and it's the kind of suite people stop
trusting.

- **Outermost** (end-to-end, system, feature, CLI invocation): one per acceptance
  criterion. Drive it the way a user reaches the behavior. Real records, no
  mocking of your own objects. Stub external HTTP only — the suite has to run
  offline. Assert through the surface you acted through: a list that still
  reads `Flagged` is the criterion failing, while `expense.flagged?` coming back
  false is a unit test hiding in an end-to-end file. If the outcome isn't visible
  from out there at all, it belongs in the boundary case below.
- **Middle** (request, API, service layer): this is your outermost layer when
  there's no UI, or when driving the UI adds machinery without adding proof.
- **Unit**: where the drop-downs land, and where the base of the pyramid comes
  from — one criterion often earns several unit examples. Test one object's
  behavior and stub its collaborators, since the point is proving this object
  works rather than re-proving theirs.

An outer test and a unit test covering the same feature aren't duplicate
coverage. The outer one asserts the user-visible outcome; the unit one asserts
the logic that produced it. Different assertions.

## Work you can't see from the outside

Background jobs, mail, and scheduled work aren't observable by driving the UI.
Assert at the boundary — that the job was enqueued, that the mail was queued —
and test the performed effect in its own test. Don't reconfigure the app to run
jobs inline so an end-to-end test can see them; that changes production behavior
to suit a test.

If two objects are painful to test apart, that's the tests telling you they're
too tightly coupled. Worth naming in your report, since the refactor step can act
on it.
