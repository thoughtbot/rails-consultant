---
type: llm
---

The commit bodies say: support checks the courier site by hand to see whether an order has left the warehouse, most "where's my order?" emails to support arrive the day after an order ships, and telling the customer as it ships should cut those down.

Judge only the PR body, not the line notes or the rest of the reply. Statements about what the code does, or doesn't do yet, aren't reasons; ignore them.

PASS if the body gives at least one of those reasons, in any wording, and no reason that isn't among them.

FAIL if the body gives a reason the commits don't, such as a customer request or a metric, or gives no reason, or there is no body.
