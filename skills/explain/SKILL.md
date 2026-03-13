---
name: explain
description: Explain what a piece of code does — translate a specific file, class, method, or snippet into plain understanding. What it does and why, not whether it's good.
argument-hint: "[file path, class name, or code snippet]"
disable-model-invocation: true
context: fork
agent: Explore
---

## Behavior

Explain `$ARGUMENTS`. Do the research and deliver the explanation in one pass.

Start by checking the git history for the file: `git log --oneline -15 <file>` and `git log -1 -p <file>` for the most recent change. Commit messages often reveal the "why" that the code itself doesn't — a bug that was fixed, a refactor that simplified something, a workaround for an external constraint. Note anything that reframes the code before diving into it.

Then read the code carefully and explain in this order:

### 1. What it does — in one paragraph

Plain English. No jargon, no code. Describe what this code accomplishes from the outside — what goes in, what comes out, what changes as a result. Write it the way you'd explain it to the client who asked for the feature.

### 2. How it does it — walking through the logic

Narrate the code path in plain English, step by step. For each meaningful chunk:

- What is this step doing?
- Why is it doing it here, in this order?
- What would break if it wasn't here?

Don't narrate every line — skip the obvious. Focus on the parts that require interpretation.

### 3. Patterns and conventions in use

Name the Rails, Ruby, or design patterns this code is using — and why they appear here. Examples:

- "This is a service object following the thoughtbot pattern — one public `call` method, one responsibility"
- "This is using `delegate` to avoid Law of Demeter violations"
- "This callback is doing what's normally done in a service object — worth noting"
- "This is a query object extracting complex AR logic out of the model"

If the code is using a pattern poorly or unexpectedly, name that too — neutrally. This isn't a review, but understanding requires knowing when something is off-label.

### 4. What to watch out for

Any non-obvious behaviour, implicit dependencies, or things that would surprise someone maintaining this code. Not a critique — just "here's what you'd need to know to work safely in this area."

---

## Tone

Clear and direct. You're translating, not teaching and not judging. The goal is that they finish with a working mental model of what this code does and how to navigate it. Skip all hedging — if something is unclear in the code itself, say so plainly.
