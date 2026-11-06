---
name: ask-claude
description: Recommend the best way to have Claude do something, checked against Anthropic's current docs, then write the prompt and run it once approved. Use when someone asks how they should prompt you, what the best way to ask for something is, or which Claude feature fits a job (CLAUDE.md, skill, hook, subagent, workflow, plan mode, /goal, MCP, headless, the API), even if they don't name a feature.
argument-hint: "[task, e.g. \"users can't sign up\" or \"run rubocop after every edit\"]"
---

# Ask Claude

Two questions sound different and are the same question: how should I ask Claude to
do this?

- "Users can't sign up." The answer is a way of working (reproduce first, plan or
  don't, what proves it's fixed) and a prompt that says it.
- "Run rubocop after every edit." The answer is a feature. A line in CLAUDE.md gets
  followed most of the time. A hook runs every time. Picking wrong means it quietly
  doesn't happen.

Either way, end with a prompt the user approves before anything runs.

```
task
  |
  v
1. look ...... the code and setup the task touches
2. read ...... the docs that apply, fetched now
3. ask ....... only what neither can tell you
4. recommend . the approach, why, and the prompt, shown for approval
5. run ....... here, as written
```

Two ways this fails. The answer comes from memory, and recommends a feature that's
been renamed, or misses the one released last month that fits better. Or the prompt
restates the task in more words and adds nothing the agent couldn't have guessed.

## 1. Look

The task is `$ARGUMENTS`, or ask for one.

Skim the README, the routes, the area the task names, recent commits there. You're
looking for what the prompt can point at: the file that handles it, the pattern to
copy, the test that covers it, the command that checks it. A prompt that names
`app/controllers/registrations_controller.rb` beats one that says "the sign-up code".

Check what's already set up too: CLAUDE.md, `.claude/settings.json` hooks,
`.claude/skills/`, `.claude/agents/`, installed skills. An installed skill that already
does the job beats writing a new one, and a hook that already exists changes the
answer.

Stay in the repo and its Claude setup. Don't search Slack, email, or other connected
tools for context. Those hold the user's own messages, and a guess built from an old
post reads like a fact. If you need something from there, ask.

## 2. Read the docs

Claude's features change month to month, so don't recommend from memory. Start at the
indexes, pick the pages that bear on this task, and read them:

- `https://code.claude.com/docs/llms.txt`: Claude Code and the Agent SDK. Skills,
  hooks, subagents, workflows, permission modes, MCP, headless runs, settings.
- `https://platform.claude.com/llms.txt`: the API, prompting, tool use, Managed
  Agents, models.

Pages worth reading for most tasks:

- `code.claude.com/docs/en/best-practices.md`: verification, explore-plan-code,
  context, when to use subagents.
- `code.claude.com/docs/en/features-overview.md`: which feature fits which goal.
- `platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md`:
  when the task is writing a prompt for something else, like a system prompt, a
  subagent, or an API call.

Then whatever the task points at: `hooks-guide.md` for "every time", `workflows.md`
for many agents, `headless.md` for CI. Two to five pages is usually enough.

Keep the URL of each page you lean on. If a fetch fails, say so and label anything
you then say from memory as such.

## 3. Ask

Ask in one turn, only what the code and docs can't answer:

- **What's happening.** Who, what they see, since when. Pasted errors, tickets, logs
  beat a description. "Some users" is a clue: which ones?
- **What should happen.** Code shows what it does, never what it should.
- **What done looks like.** Diagnose and report, or fix? A fix they'll ship, or a
  spike to estimate from? For a feature: just me, or the whole team via git?

"Don't know" is a fine answer. It goes in the prompt as an unknown.

## 4. Recommend

Lead with the approach, then the prompt that carries it out:

````
**Approach:** a PostToolUse hook in .claude/settings.json that runs rubocop on the
edited file.

**Why:** "Unlike CLAUDE.md instructions which are advisory, hooks are deterministic
and guarantee the action happens."
https://code.claude.com/docs/en/best-practices.md

**Not:**
- CLAUDE.md line: followed most of the time, not every time.
- Stop hook: runs once per turn, so a bad edit lingers until the end.

```
Add a PostToolUse hook to .claude/settings.json (checked in, so the team gets it)
that runs `bundle exec rubocop -a` on the file Claude just edited, for Edit and
Write only. Read https://code.claude.com/docs/en/hooks.md for the input format
first.

Done when: editing app/models/user.rb with a style offense gets auto-corrected,
and an offense rubocop can't fix shows up for Claude to handle. Show the
settings.json diff and the hook firing once.
```

Change anything, or run it?
````

The **Why** quotes or points at the doc, so the user can check it. **Not** names the
one or two alternatives they'd likely reach for, and what's wrong with each. Skip it
when nothing else was close.

The best answer isn't always a Claude feature. "Post a ticket digest every morning"
might be a background job in the app, if the app already has a scheduler, a Slack
client, and an LLM gem. That version gets code review, tests, and error tracking,
and doesn't stop when one person's account does. Weigh plain code alongside Claude's
features and pick whichever fits; the docs tell you what Claude can do, not whether
it should.

For a coding task the approach is how to work, and the prompt carries most of the
weight. Write it the way you'd brief a sharp colleague who's never seen this app.
Use only the parts that earn their place:

- **The ask, said outright.** "Find out why and fix it" and "find out why, change
  nothing" get different work. Say which.
- **What we know, and from whom.** The user's words, pasted evidence, and a source
  on each claim: user, ticket, unverified. The agent weighs a guess and a log line
  differently only if it can tell them apart.
- **Where to look.** Files, routes, commits you found in step 1, with paths.
- **The why behind each constraint.** "Don't touch the Google credentials, they're
  shared with the mobile app" gets followed more sensibly than "NEVER touch
  credentials". Skip ALL-CAPS; it makes agents overreact.
- **How to work, when the task needs it.** Bug: reproduce before fixing, with a
  failing test or `/trace`. Unclear approach or many files: plan mode first. Broad
  reading: subagents, each with a narrow question. Diff you could describe in one
  sentence: none of this.
- **Out of scope.** What not to touch, what not to add. Agents widen tasks on their
  own.
- **Done when.** A check that runs, named exactly: `bin/rspec
  spec/requests/auth_callbacks_spec.rb` passes, not "the spec passes". Use the
  project's own test command from step 1. Then what to report: the cause in a line,
  the command and its output as proof, what changed, what it couldn't check.
- **Can't reach.** Production data, error trackers, third-party dashboards. Say so,
  so a finding from development isn't read as one from production.

Say what to do, not only what to avoid. Plain prose and short lists; wrap pasted
material in tags like `<ticket>` so it's clearly data.

If another skill fits better, that's the approach: `/slice` for a feature that isn't
scoped yet, `/domain-model` when the business process itself is unclear.

Then stop. Don't run a prompt they haven't seen. A wrong assumption costs a sentence
to fix now and an hour of work later.

## 5. Run it

On approval, do what the prompt says, here, as if they'd typed it. Edits: revise,
show it again.

If it'd go better elsewhere, say so and let them pick: a fresh session for a big
task, plan mode for an unclear one. The prompt stands on its own, so it can be
pasted there as is.
