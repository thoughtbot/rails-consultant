---
name: offboard
description: Wrap up a client engagement — produce handoff documents, stakeholder summary, and questions for the client. Leave the project in the best possible shape.
argument-hint: "[optional engagement context]"
disable-model-invocation: true
---

## Behavior

This is a conversational planning session that produces concrete handoff documents. Start by understanding the engagement.

Open with:

**"Tell me about the engagement — what did you build or work on, and when are you rolling off?"**

Wait for their answer. Then ask one at a time:

**"What's still in flight — anything unfinished, in progress, or that you'd want another week to get right?"**

Wait. Then:

**"Who's going to own this after you leave — the client's team, another contractor, or nobody yet?"**

Wait. Then:

**"What's the thing you're most worried about happening after you're gone?"**

Wait for their answer. Then push — don't take the first answer at face value:

**"Is that really the biggest risk, or is that the one you're comfortable naming? What's the thing you'd be embarrassed for the next developer to find?"**

Wait for their answer. This matters because consultants instinctively frame their exit charitably. The handoff documents are only as honest as the answers that feed them.

Wait for all answers before producing anything. These shape everything — who the audience is, what needs emphasis, and what risks to surface.

---

### Research Phase

Before writing the handoff documents, explore the codebase for context:

- `git log --oneline --since="3 months ago" --author=<user>` (or reasonable timeframe) — what did you actually touch?
- `git log --oneline -30` — recent activity and state of the codebase
- `git branch -a` — any open feature branches that need attention?
- `git stash list` — anything stashed and forgotten?
- Check for open TODOs or FIXMEs the user may have left
- Check for any pending migrations not yet run in production
- Check CI config if visible — is the pipeline green?

---

### Deliverable 1: Handoff Document

Produce a comprehensive handoff document structured for the person who takes over. Write it in markdown, ready to paste into a wiki, Notion, or repo README.

**Title:** `Handoff: [Project/Feature Name] — [Date]`

**What was built** — a clear summary of what was delivered during the engagement. Written for someone who wasn't there. Cover:
- Features or systems built or significantly changed
- Key architectural decisions and why they were made
- Anything that was descoped or deferred, and why

**Current state** — where things stand right now:
- What's shipped and stable
- What's in progress (with status and what's left)
- What's been started but not finished
- Open PRs or branches that need attention

**How to work in this area** — the practical guide for the next developer:
- Key files and directories they'll need to know
- Patterns and conventions used (reference existing codebase conventions)
- How to run, test, and deploy the relevant parts
- Any local setup gotchas or environment-specific notes

**Known risks and technical debt** — be honest about what you're leaving behind:
- Known bugs or edge cases you didn't get to
- Technical debt you introduced intentionally (and why)
- Areas of the code that are fragile or under-tested
- Performance concerns at scale
- Dependencies that need attention (outdated gems, deprecated APIs)

**Recommendations** — what you'd do next if you were staying:
- Prioritized list of what to tackle next
- Things that will break if ignored
- Improvements that would be valuable but aren't urgent
- Anything you'd refactor given more time

---

### Deliverable 2: Stakeholder Summary

A separate, shorter document for the client / non-technical stakeholders. Different audience, different tone — no code, no jargon.

**Title:** `Engagement Summary: [Project/Feature Name] — [Date]`

**What was accomplished** — plain-language summary of what was delivered and the value it provides. Frame in terms of what users can now do, not what code was written.

**What's in progress** — anything still in flight, with clear status and expected next steps. No surprises.

**What needs attention** — 2–3 things the client should be aware of going forward. Not a scare list — a prioritized, actionable set of items. Frame as "here's what will keep this running well" not "here's what's broken."

**Recommendations for the team** — practical suggestions for the team going forward:
- Skills or knowledge gaps to fill
- Process improvements worth considering
- When to bring in outside help again (if relevant)

**It was a pleasure** — close warmly. Acknowledge the team, the collaboration, and what you learned. This isn't filler — it's how you end on a high note and get called back. Be specific about what worked well in the partnership.

---

### Deliverable 3: Questions for the Client

Before rolling off, surface 3–5 questions worth discussing with the client in a final meeting:

- "Are there any areas where you feel uncertain about what happens after I leave?"
- "Is there anything I built that your team needs a walkthrough on?"
- "What worked well in how we collaborated — and what would you change next time?"
- "Is there anything in the recommendations that you'd want me to prioritize before my last day?"

Tailor these to the specific engagement — if there's a risky area, ask about it directly. If handoff to a specific person is happening, ask what would make that transition smoothest.

---

After producing all three deliverables, close with:

**"Read through the stakeholder summary — does it accurately represent what was accomplished? The client will remember this document more than the code."**

Wait for their answer. Respond with one short paragraph: whether the summary lands as a confident, honest account of the work, or whether it undersells or oversells — and what to adjust.

## Tone

Professional and warm. This is the last impression you leave. Be thorough but not exhaustive — the handoff should feel organised and confident, not anxious. Honesty about risks builds more trust than pretending everything is perfect. End on a note that makes the client glad they hired you and open to working together again.
