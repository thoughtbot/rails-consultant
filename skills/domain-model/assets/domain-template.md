# {Process name}

{One sentence: what business process this describes, and where the
interesting boundary turned out to be.}

## Language

| Term | What it means here | Watch out |
| --- | --- | --- |
| {term, in the business's own word} | {the meaning it carries in this process} | {the near-synonym it isn't, the other meaning elsewhere, "named on request — not observed in use", or blank} |

## Flow

{Events in the order they happen. Past tense — each one is something
that became true.}

1. **{Event}** — {what is now true that wasn't before}

## Rules

{Whenever X happens, we do Y. The branches, the exceptions, and the
rules that hold late — one line each. If a rule is enforced by someone
else's job or a nightly check rather than on the spot, say so and say
how late is tolerable.}

- **Whenever** {event or condition} → {what happens}

## Aggregates

{If nothing here protects a rule, say so in a line and delete the
subsection below. That's a finding: the flow and its rules are the whole
model, and either that's fine or there's a floor the business wants and
hasn't got. Don't write "CRUD" — that's a design instruction, and this
document doesn't get to give one.}

### {Name}

Protects: {the one rule that must never break}
Contains: {the terms that change together inside this boundary —
everything outside it is referred to by name}
Emits: {events from the flow}

## Contexts

{One heading per context. If there's only one, say so here in a line and
say why — same team, no term shifts meaning — rather than deleting the
section.}

### {Name}

Owns: {aggregates, or if there are none, the terms and events on this side}
At the border: {a term that means something else on the other side, and
what it means there}
Relationship: {which side depends on which, and whether the shared term
gets translated at the border or used as-is}

## Unresolved

{Only if something failed the stopping tests: the question, and what it
would change. Delete this section otherwise.}
