---
description: A developer names the skill and brings a stuck bug with their own wrong read of it, so the first turn plays that read back, names the guess in it without settling it, and doesn't go find or fix the real cause in the renewal job.
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Edit, Write]
---

Let's rubber duck this. Customers who cancel are still getting charged on their renewal date. I've been staring at app/models/subscription.rb for an hour. cancel! sets canceled_at, active? checks canceled_at, and renewals go through renew! which bails unless active?. So a canceled subscription should never get charged. I don't get how they're slipping through.
