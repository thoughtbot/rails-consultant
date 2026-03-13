# Example: /flow password reset

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
