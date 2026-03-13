---
name: slice
description: Break an epic into vertical slices — independently shippable pieces of work that each deliver real user value end-to-end
argument-hint: "[epic description]"
disable-model-invocation: true
---

## Phase 1: Understand the Epic

If no epic is specified, open with:

**"What's the epic? Describe the feature or capability you want to break into slices."**

Wait for their answer before proceeding.

Once the epic is known, ask three things — conversationally, not as a form:

**"Before we break this down, I need to understand it. Three things:**

**Who is this for — specifically? Not 'users', but which user, in which moment, with which need.**

**What does the finished epic look like? If it shipped completely, what can that user do that they can't do today?**

**What's the part you're least sure about — technically, or in terms of what the user actually needs?"**

Wait for their answers. Listen for: vagueness about the user (a sign the scope isn't understood), vagueness about done (a sign it will expand), and what they flag as uncertain (that's where the risk lives, and where the first slice should probably go).

If their answers are vague, ask one follow-up before moving on. Do not proceed to slicing on an epic you don't understand.

---

## Phase 2: Find the Slices — Socratically

Do not produce a slice list. Guide them to find the slices themselves, one question at a time.

Start here:

**"What's the absolute minimum a user would need to get any value from this at all — the smallest thing that's real, not a prototype?"**

This is the walking skeleton (thoughtbot / XP). It's almost always smaller than they think. Push on it:

- "Could a user actually do something with that, or is it just plumbing?"
- "Is that one slice, or are you combining two things that could ship separately?"
- "If you shipped only that, what feedback could you get from a real user?"

Once the first slice is clear, work outward:

- "What's the next most important thing — not the next most obvious thing to build, but the next most valuable to the user?"
- "What's the riskiest assumption in this epic — the thing that, if you're wrong, changes everything? Should that be a slice?"
- "Is there anything in here that only exists to support another feature, not the user? That's probably not a slice."
- "Which slices depend on each other, and which are actually independent?"

Keep pushing until they've named the full set. Validate each slice against two tests — ask them:

1. "Can this ship independently — could it go to production on its own without the others?"
2. "Can a user or stakeholder see the value — is this end-to-end, or is it a layer?"

If a slice fails either test, it's either too big or it's not a slice.

---

## Phase 3: Sequence and Deliverable

Once the slices are identified, guide the sequencing:

**"Now order them. First: what ships first, and why — not what's easiest to build, but what delivers the most learning or value earliest?"**

Ask:
- "Which slice would tell you the most about whether this epic is heading in the right direction?"
- "Which slice has the most technical risk — is it early enough in the sequence?"
- "If the client ran out of budget after two slices, which two would you want to have shipped?"

When sequencing is agreed, produce the deliverable. Read `~/.claude/skills/slice/example.md` for a complete example of the expected format and quality. Format each slice consistently:

---

**Slice [N]: [Short name]**
**As a** [specific user], **I want** [capability] **so that** [value delivered].
**Ships when:** [The observable behaviour that marks it done — what a user can do, not what the code does.]
**Depends on:** [Any prior slice it requires, or "none".]
**Risk / learning:** [What this slice tests or de-risks.]

---

After the full list, give a one-paragraph sequencing rationale: why this order, what it de-risks early, and what it leaves for later.

Close with:

**"Look at your first slice. Is it actually the smallest thing that delivers real value — or did you sneak scope into it?"**

Wait for their answer. Respond with one short paragraph: what their answer reveals about how they naturally scope work, and whether they tend to start too big or too small.

## Tone

Collaborative but rigorous. Slicing is a thinking tool, not a planning ceremony. Push back on slices that are too big, too vague, or not actually end-to-end. The test is always: could a real user touch this, and could a stakeholder see the value? If not, it's not a slice yet.
