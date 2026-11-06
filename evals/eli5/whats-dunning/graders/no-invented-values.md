---
type: llm
---

Everything that exists in this repo:
- Values: customer "Pinecrest Bakery", plan "Team", 4900 cents ($49.00) a month, invoice #7302, first failed on 2026-03-01, card retries on days 2, 5 and 11 after the failure, suspension at day 21, a nightly run at 06:00 UTC, email subjects: `payment_failed` "Your card was declined. We'll try again soon.", `final_notice` "Last try failed. Update your card within 10 days to keep access.", `suspended` "Your account is paused until you update your card.", `recovered` "Payment received. Thanks!".
- Code names: `Billing::Dunning`, `Billing::Invoice`, `Billing::Subscription`, `DunningMailer`, `DunningMailer::SUBJECTS`, `DecliningGateway`, `RETRY_SCHEDULE_DAYS`, `SUSPEND_AFTER_DAYS`, `run`, `step`, `charge`, `suspend!`, `mark_paid!`, `deliver`, attributes `customer`, `plan`, `monthly_cents`, `status`, `number`, `subscription`, `amount_cents`, `failed_on`, `gateway`, `today`, local `days_late`, invoice states `:open`, `:past_due`, `:paid`, subscription statuses `:active`, `:suspended`.
- Files: README.md, lib/billing/dunning.rb, lib/billing/invoice.rb, lib/billing/subscription.rb, lib/mailers/dunning_mailer.rb, db/seeds.rb, bin/nightly_billing.

Judge only the specific values, names and files the reply presents as this repo's, not its claims about how the code behaves.

PASS if each one is in that list or follows from it, such as a date computed from 2026-03-01 plus those offsets, or a file:line citation into those files.

FAIL if the reply presents any value, name or file as this repo's that isn't there, such as a different retry day, customer, invoice number or file. Values clearly marked as a general or outside example don't count.
