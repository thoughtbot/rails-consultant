---
type: llm
focus: trace
---

The repo computes the order total (line item subtotal, 8% tax, $5.99 shipping under $50) in three separate copies: `Order#total_cents` in app/models/order.rb, `OrderMailer#receipt` in app/mailers/order_mailer.rb, and the private methods of `InvoicePdf` in app/pdfs/invoice_pdf.rb.

PASS if a message from Claude to the user says the total math is duplicated and names all three places: Order, OrderMailer, and InvoicePdf.

FAIL if no message says the math is duplicated, or the messages leave any of the three out.
