# Running and recording a trace

Drive the entry point with a script that loads the app, record what leaves the
process, record in order. Look for what the stack already gives you before
writing your own.

## Drive it

A script in a gitignored folder that imports the app's own code and runs the
entry point in development:

- **A web handler:** use the framework's in-process request helper if it has
  one that works outside the test runner (Rails:
  `ActionDispatch::Integration::Session`). Otherwise build the request object
  the framework passes in and call the handler directly.
- **A page or view that loads data:** call the data-loading function it calls,
  with the same arguments.
- **A CLI command or job:** invoke it the way the app's own entry point does.

Auth: create the user and whatever session or token record the app checks,
then sign in through the app's real sign-in route, the way a browser would. If
the auth library can't be satisfied from a script, call the code just past the
auth check, and mark the auth check `read`.

Development guards can block a scripted request: a host allowlist, a CSRF
token check, mail that opens a browser tab. Turn each off for the script only,
and list it in the trace's Holes.

An in-process request can leave per-request state behind that breaks the
script's next query. Rails: a `NoMethodError` from query logging after a
request; call `ActiveSupport::ExecutionContext.clear` after each one.

When nothing can be driven in-process, start the dev server on a spare port,
send a real request, and stop the server.

## Record outside calls

Wrap the outgoing HTTP function in the script before the scenario runs: log
the call, then pass it through. In JavaScript and TypeScript that's usually
`globalThis.fetch`:

```ts
const realFetch = globalThis.fetch;
globalThis.fetch = async (input, init) => {
  const url = String(input instanceof Request ? input.url : input);
  console.log("TRACE http", init?.method ?? "GET", url, init?.body ?? "");
  return realFetch(input, init);
};
```

Check the app doesn't use a different HTTP client (axios, got, Faraday, an SDK
with its own transport); if it does, wrap that. Ruby has no single function to
wrap; WebMock's `after_request` callback with `allow_net_connect!` records
without blocking.

Destructive calls (process kills, dropping a database, deleting or moving files
outside the repo): replace the function the app calls with one that records the
arguments and returns, or point its configured directory at a temp folder.

## Record

- **The framework's own events**, if it has them. Rails:
  `ActiveSupport::Notifications.subscribe` to `sql.active_record`,
  `enqueue.active_job`, `perform.active_job`, `deliver.action_mailer`,
  `redirect_to.action_controller`, `broadcast.action_cable`.
- **Queries:** otherwise the ORM's query log or event. Prisma:
  `new PrismaClient({ log: [{ emit: "event", level: "query" }] })` and
  `prisma.$on("query", e => ...)`. Keep writes; keep reads only when there are
  suspiciously many.
- **Where a write came from:** some query logs print the calling `file:line`
  under each query (Rails: `verbose_query_logs`). Note the log's size before
  and read only what this run appended.
- **Log level:** most frameworks log requests and queries at debug. Turn it up
  for the one run and filter.
- **Background work:** switch the job backend to one that holds jobs (Rails:
  `ActiveJob::Base.queue_adapter = :test`), or replace the enqueue function
  with one that records and holds. After the request returns, run the held
  jobs yourself, one level at a time.
- **Print statements** at each step's entry and exit, as a last resort, in a
  copy you delete after.

Tag every line `TRACE ...` so it filters out of the noise.
