---
type: llm
focus: trace
---

The app already exports customers to CSV: `Customer.to_csv` in app/models/customer.rb, served by the `format.csv` branch of `CustomersController#index`.

PASS if a message from Claude to the user points to that customer CSV export, by class, method, or file path, as something the invoice export can reuse or copy.

FAIL if no message from Claude mentions the existing customer CSV export.
