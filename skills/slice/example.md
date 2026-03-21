# Example: /slice Users need to be able to manage their subscription

**Slice 1: Subscribe to a plan**
**As a** new customer on the pricing page, **I want** to choose a plan and enter payment details **so that** I have an active subscription.
**Ships when:** A user can select a plan, enter a credit card, and see a confirmation page showing their active subscription.
**Acceptance criteria:**

- [ ] User can see available plans with names, prices, and billing frequency
- [ ] User can enter credit card details via Stripe checkout
- [ ] Successful payment creates an active subscription record
- [ ] User sees a confirmation page with plan name and next billing date
- [ ] Declined card shows a clear error message without creating a subscription
      **Depends on:** None.
      **Risk / learning:** Validates the Stripe integration works end-to-end. If this is painful, every subsequent slice will be too — surface it first.

**Slice 2: View current subscription**
**As a** subscribed customer, **I want** to see my current plan, billing date, and payment method **so that** I know what I'm paying and when.
**Ships when:** A logged-in subscriber sees a billing page showing plan name, next billing date, and last 4 digits of their card.
**Acceptance criteria:**

- [ ] Billing page is accessible from account navigation
- [ ] Page displays current plan name and price
- [ ] Page displays next billing date
- [ ] Page displays last 4 digits of card on file
- [ ] Non-subscribed users see a prompt to subscribe instead of billing details
      **Depends on:** Slice 1.
      **Risk / learning:** Forces the data model to be right — if the subscription record doesn't store what we need, we find out here.

**Slice 3: Cancel subscription**
**As a** subscribed customer, **I want** to cancel my subscription **so that** I stop being charged.
**Ships when:** A subscriber can click "cancel", sees a confirmation, and their subscription is marked as cancelling (active until end of billing period). No more charges after the period ends.
**Acceptance criteria:**

- [ ] Cancel button is visible on the billing page for active subscribers
- [ ] Clicking cancel shows a confirmation dialog before proceeding
- [ ] After confirming, subscription status changes to "cancelling"
- [ ] User retains access until the end of the current billing period
- [ ] Stripe cancellation webhook updates the local subscription record when the period ends
- [ ] Cancelled users see a prompt to resubscribe on the billing page
      **Depends on:** Slice 2 (needs the billing page to put the cancel button on).
      **Risk / learning:** Tests the Stripe cancellation webhook flow — does our system correctly handle the async state change?

**Slice 4: Change plan**
**As a** subscribed customer, **I want** to upgrade or downgrade my plan **so that** I get the features I need without overpaying.
**Ships when:** A subscriber can switch between plans, sees the prorated cost, and the change takes effect immediately.
**Acceptance criteria:**

- [ ] User can see other available plans from the billing page
- [ ] Switching plans shows the prorated cost before confirming
- [ ] Plan change takes effect immediately after confirmation
- [ ] User's next billing amount reflects the new plan
- [ ] Attempting to switch to the current plan is a no-op (button disabled or hidden)
      **Depends on:** Slice 2.
      **Risk / learning:** Proration logic is the most complex billing calculation. Deferring this until Stripe basics are proven.

**Slice 5: Update payment method**
**As a** subscribed customer, **I want** to update my credit card **so that** my subscription doesn't lapse when my card expires.
**Ships when:** A subscriber can enter a new card on the billing page and see it reflected as their active payment method.
**Acceptance criteria:**

- [ ] Update payment button is visible on the billing page
- [ ] User can enter new card details via Stripe checkout
- [ ] Successful update shows the new card's last 4 digits on the billing page
- [ ] Failed card update shows an error and retains the previous payment method
      **Depends on:** Slice 2.
      **Risk / learning:** Low risk — straightforward Stripe API call. Sequenced last because it's high value but low uncertainty.

**Sequencing rationale:** Slice 1 proves the Stripe integration works. Slice 2 builds the billing page that every subsequent slice needs as a home. Slices 3–5 are independent of each other and ordered by risk: cancellation tests webhooks, plan changes test proration, payment update is a known quantity. If the client runs out of budget after slice 3, subscribers can sign up, see their billing, and cancel — a complete if minimal subscription experience.
