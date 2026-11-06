# Reading a failure

Match on what the failure *is*, not on the phase you think you're in. Frameworks
word these differently; the shape is what matters. Work the first failure, not
the one you find most interesting.

| The failure | What it means | Next move |
| --- | --- | --- |
| The test command isn't recognized, or the suite won't load at all | You guessed the layout | Find how this repo actually runs tests |
| Pending migration, stale schema, or the suite aborts before any test runs | Environment, not code | Prepare the test schema, start the service. Not a code gap |
| Setup code raised — factory, fixture, helper | Your Arrange is broken | Fix the setup |
| Unresolved symbol or import at compile or collection time | This *is* a code gap | Use the domain-object or framework-class row below, whichever fits |
| No route, no such subcommand, no entry point in the thing you're building | Outer plumbing gap | Smallest entry point that produces a different failure |
| Missing template, view, renderer, or output target | Render gap | Thinnest possible output. Empty is fine |
| Redirected, bounced to a sign-in, or forbidden | Arrange gap | Authenticate as someone allowed to do this. Don't invent collaborators |
| Expected content absent, and you're on the right page | The data isn't exposed yet | Write the literal where it renders. Invent a collaborator only if a literal can't say it |
| Missing table or column | Schema gap | Generate and run the migration — that *is* the smallest change |
| Undefined method on a domain object you own | **Drop down** | Unit-test that one behavior, green, come back up |
| Undefined framework class — controller, job, mailer, serializer | Framework plumbing | Create the thinnest one where you stand. Don't drop down |
| Wrong argument count or type at a call you just wrote | Caller and signature disagree | Fix the call site, or extend the signature where you stand |
| Expected X, got Y | Behavior is wrong | Shameless green: explicit, readable, one case at a time |
| Passes the moment you write it | It may already be built | Read the code. If it exists, say so and move on. If not, break it on purpose to prove the test can fail |
| Tests you didn't write went red | Regression | Read the first one. If one cause explains several, fix the cause |
| Passes alone, fails in the suite | Order dependence or leaked state | Re-run with the same seed before believing it |
| The same failure after two different fixes | You're guessing | Stop and report what you don't understand |

## Drop down, then come back up

One failure moves you down a layer: a method missing from a domain object you
own. Framework classes you create where you stand — a controller has no behavior
of its own to unit-test yet, and the layer beneath an end-to-end test is usually
a request or service test, not a test of the framework class.

Dropping down isn't switching tasks. The outer test is still red and still in
charge. Unit-test exactly the behavior the outer failure named, no more, get it
green, then re-run the outer test and let its new message choose what's next.

## When the message doesn't change

An unchanged message is information, not a verdict. Two things produce it: a
change that was necessary but not sufficient — a migration, one of several
co-required pieces — and a guess. Say which you think it is. If you can name the
next thing your change unblocks, keep it and carry on. If you can't, drop it
rather than stack a second guess on top of it.

Two unchanged messages in a row means stop.

## Out of bounds

The failure is the specification. These moves fake agreement with it, and each
one trades a question about the code for a bug that surfaces later:

`skip`, `xit`, or `pending` on a test you can't pass. `sleep` to settle a race.
Loosening an exact assertion to a truthiness check, widening a matcher, or
deleting an example. `--fail-fast` to hide the remaining reds.

Change a test only once you've found the test itself is wrong, and say so when
you do.
