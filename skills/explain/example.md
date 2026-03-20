# Example: /explain password reset

```
                    ┌──────────────────────┐
                    │  User forgot password │
                    └──────────┬───────────┘
                               │
                               ▼
                    POST /passwords (email)
                               │
                       user found by email?
                      ┌────────┴────────┐
                      │ NO              │ YES
                      ▼                 ▼
                 (same response)   Generate reset token
                      │                 │
                      │            Send reset email
                      │                 │
                      └────────┬────────┘
                               │
                               ▼
                  redirect to login ("Check your email")
                               │
                               │
                    ┌──────────┴───────────┐
                    │  User clicks email   │
                    └──────────┬───────────┘
                               │
                               ▼
                  GET /passwords/:token/edit
                               │
                        token valid?
                      ┌────────┴────────┐
                      │ NO              │ YES
                      ▼                 ▼
                redirect to         render password
                new_password_path   reset form
                                        │
                                        ▼
                              PATCH /passwords/:token
                                        │
                                 password valid?
                               ┌────────┴────────┐
                               │ NO              │ YES
                               ▼                 ▼
                          render form       Update password
                          with errors       Clear reset token
                                                │
                                           Log user in
                                                │
                                                ▼
                                        redirect to dashboard
```

### Entry Points

1. **User submits email** — `POST /passwords` looks up the user and sends a reset email. Returns the same response whether the user exists or not to prevent email enumeration.
2. **User clicks reset link** — `GET /passwords/:token/edit` validates the token and renders the password form if valid.
3. **User submits new password** — `PATCH /passwords/:token` updates the password and logs the user in.

### Branching Logic

- **User existence**: Email lookup determines whether a reset email is sent, but the HTTP response is identical either way — no information leakage.
- **Token validity**: Token must exist and not be expired. Invalid tokens redirect back to the "forgot password" form.
- **Password validation**: `has_secure_password` validates presence, length, and confirmation match.

### Side Effects

- **Reset token written to DB** — stored as a SHA256 digest, not plain text
- **Email enqueued** — `PasswordMailer.reset_instructions` delivered via background job (Sidekiq)
- **Session created** — user is automatically logged in after successful reset
- **Token cleared** — `after_update` callback removes the reset token so it can't be reused
