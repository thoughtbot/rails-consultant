---
name: flow
description: Generate an ASCII call graph tracing the code path for a given user flow or feature in the current Rails codebase
argument-hint: "[flow description, e.g. authentication, checkout, password reset]"
disable-model-invocation: true
context: fork
agent: Explore
---

## Behavior

Trace the flow for `$ARGUMENTS`. If the flow is genuinely ambiguous (e.g. multiple authentication strategies, multiple checkout flows), trace the most common path and note the alternatives in the summary.

### Step 1: Find the Entry Point

Start with the Rails router. Locate the route(s) that correspond to the described flow. Look for:

- `config/routes.rb` and any `draw` files it loads
- The HTTP verb and path
- The controller and action it maps to

If there are multiple relevant routes (e.g. GET + POST for a form), include all of them as separate root nodes.

### Step 2: Trace the Code Path

From each entry point, trace the full execution path through the codebase. Follow:

- **`before_action` callbacks** — on the controller and any inherited controllers (ApplicationController, etc.)
- **Controller action** — what it calls, in order
- **Service objects / operation objects / form objects** — follow them into their `call`, `perform`, or `run` methods
- **Model methods** — any significant domain logic called
- **ActiveRecord callbacks** — `before_save`, `after_create`, etc., if they're part of the flow
- **Jobs / mailers** — if enqueued or delivered as part of the flow
- **Response / redirect** — what happens at the end (render, redirect_to, respond_with)

Trace branch points explicitly — success paths and failure paths both matter.

Limit depth to what's meaningful. Don't descend into Rails internals or gem source. Stop at the boundary of application code.

### Step 3: Render the Call Graph

Format the output as an ASCII call graph using this convention:

```
VERB /path  →  Controller#action
│
├── before_action :method_name          # annotation if useful
│   └── SomeClass.method
│
├── Controller#action
│   ├── Model.find_by(...)
│   ├── ServiceObject.call(...)
│   │   ├── model.some_method
│   │   │   └── AnotherModel.where(...)
│   │   ├── [success] →
│   │   │   ├── SomeMailer.deliver_later
│   │   │   └── SomeJob.perform_later
│   │   └── [failure] →
│   │       └── errors added to model
│   │
│   ├── [success] → redirect_to path
│   └── [failure] → render :template
```

**Conventions:**

- `├──` non-last sibling, `└──` last sibling, `│` continuation
- `[success] →` and `[failure] →` for explicit branch points
- `# comment` for brief annotations (callbacks, notable side effects)
- File path in parentheses for key nodes: `ServiceObject.call (app/services/service_object.rb:42)`
- Omit trivial getter/setter calls; include anything that has logic or side effects

### Step 4: Git History

For each key file involved in the flow (controller, service objects, significant models), run `git log --oneline -10 <file>` to surface recent changes. Look for:

- Recent modifications that might explain current behaviour or unusual patterns
- Commit messages that reveal intent ("fix edge case where...", "extract from...", "revert...")
- Files that changed together frequently — a signal of hidden coupling
- Anything that looks like a recent hotfix or workaround in the flow

Include a brief **Git context** note in the summary if anything significant surfaces. Skip this section silently if the history is unremarkable.

### Step 5: Summary

After the graph, add a short section:

**Entry points:** List the routes covered.
**Key decision points:** The 1–3 branch conditions that shape the flow (e.g. "authentication succeeds or fails", "record valid or invalid").
**Notable side effects:** Jobs, mailers, external calls, cache writes — anything with consequences outside the request.
**Git context:** Any recent changes to files in the flow worth knowing about — hotfixes, rewrites, reverts. Omit if unremarkable.
**Blind spots:** Any part of the flow where the code path couldn't be fully traced (missing files, dynamic dispatch, STI, etc.) — flag these rather than silently omitting them.

---

## Output Format

Return the graph in a fenced code block so it renders in fixed-width. Follow it with the plain-text summary outside the block.

The following is a complete example of the expected format, depth, and annotation style. Match it.

### Example: /flow password reset

```
GET /passwords/new  →  PasswordsController#new
│
└── PasswordsController#new
    └── render :new                                    # form with email field


POST /passwords  →  PasswordsController#create
│
├── before_action :rate_limit_password_resets           # custom throttling
│   └── RateLimiter.check!(:password_reset, ip:)       (app/services/rate_limiter.rb:12)
│
└── PasswordsController#create
    ├── User.find_by(email: params[:email])
    ├── [user found] →
    │   ├── user.generate_password_reset_token!
    │   │   └── before_save :hash_token                 # AR callback
    │   ├── PasswordMailer.reset_instructions(user).deliver_later
    │   │   └── ResetJob enqueued                       # sidekiq
    │   └── redirect_to login_path, notice: "Check your email"
    └── [user not found] →
        └── redirect_to login_path, notice: "Check your email"   # same response, no leak


GET /passwords/:token/edit  →  PasswordsController#edit
│
└── PasswordsController#edit
    ├── User.find_by_password_reset_token(params[:token])
    │   └── FindByResetToken.call(params[:token])       (app/services/find_by_reset_token.rb:8)
    │       ├── hash token with SHA256
    │       └── User.find_by(password_reset_digest:)
    ├── [token valid] →
    │   └── render :edit                                # form with new password fields
    └── [token invalid or expired] →
        └── redirect_to new_password_path, alert: "Invalid or expired link"


PATCH /passwords/:token  →  PasswordsController#update
│
└── PasswordsController#update
    ├── User.find_by_password_reset_token(params[:token])
    ├── [token valid] →
    │   ├── user.update(password:, password_confirmation:)
    │   │   ├── has_secure_password validation
    │   │   └── after_update :clear_password_reset_token
    │   ├── [valid] →
    │   │   ├── SessionManager.login!(user, session)    (app/services/session_manager.rb:15)
    │   │   └── redirect_to dashboard_path
    │   └── [invalid] →
    │       └── render :edit
    └── [token invalid or expired] →
        └── redirect_to new_password_path, alert: "Invalid or expired link"
```

**Entry points:** `GET /passwords/new`, `POST /passwords`, `GET /passwords/:token/edit`, `PATCH /passwords/:token`

**Key decision points:** (1) user found or not found on email lookup — response is identical to prevent enumeration, (2) token valid or expired, (3) new password valid or invalid.

**Notable side effects:** `PasswordMailer.reset_instructions` enqueued via Sidekiq; password reset token written to DB with hashed digest; session created on successful reset.

**Git context:** `find_by_reset_token.rb` was added 3 weeks ago (previously inline in controller) — commit message: "extract token lookup to prevent timing attacks."

**Blind spots:** Rate limiter implementation delegates to Redis — couldn't trace the full throttling logic from application code.

## Tone

Precise and terse. This is a reference artifact, not an explanation. Annotate only when something would be non-obvious to a reader who knows Rails. Accuracy over completeness — flag uncertainty rather than guess.
