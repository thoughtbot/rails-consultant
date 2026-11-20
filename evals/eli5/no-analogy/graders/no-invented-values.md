---
type: llm
---

Everything that exists in this repo:

- Values: customer "Pinecrest Bakery", plan "Team", 4900 cents ($49.00) a month, invoice #7302, first failed on 2026-03-01, card retries on days 2, 5 and 11 after the failure, suspension at day 21, a nightly run at 06:00 UTC, email subjects: `payment_failed` "Your card was declined. We'll try again soon.", `final_notice` "Last try failed. Update your card within 10 days to keep access.", `suspended` "Your account is paused until you update your card.", `recovered` "Payment received. Thanks!".
- Code names: `Billing::Dunning`, `Billing::Invoice`, `Billing::Subscription`, `DunningMailer`, `DunningMailer::SUBJECTS`, `DecliningGateway`, `RETRY_SCHEDULE_DAYS`, `SUSPEND_AFTER_DAYS`, `run`, `step`, `charge`, `suspend!`, `mark_paid!`, `deliver`, attributes `customer`, `plan`, `monthly_cents`, `status`, `number`, `subscription`, `amount_cents`, `failed_on`, `gateway`, `today`, local `days_late`, invoice states `:open`, `:past_due`, `:paid`, subscription statuses `:active`, `:suspended`.
- Files: README.md, lib/billing/dunning.rb, lib/billing/invoice.rb, lib/billing/subscription.rb, lib/mailers/dunning_mailer.rb, db/seeds.rb, bin/nightly_billing.

Judge only the specific values, names and files the reply presents as this repo's, not its claims about how the code behaves.

These all follow from the list and are fine:

- Dates and day counts computed from it, in any format: "Mar 3", "2026-03-22", "day 22", "three weeks", "21 − 11".
- Shortened or cut-off quotes of the email subjects: "Payment received.", "Update your card within 10 days...".
- Names joined from listed parts: `DunningMailer.deliver`, `Billing::Dunning#run`, `RETRY_SCHEDULE_DAYS = [2, 5, 11]`.
- Plain words that aren't presented as code names: "gateway", "scheduled job", "fake gateway".
- Values clearly marked as a general or outside example.

PASS unless you can point to a specific value, name or file the reply presents as this repo's that isn't in the list and doesn't follow from it.

FAIL if you can: a different retry day, customer, amount, invoice number, email subject, code name or file. Name it in your reason.
