---
name: pr
description: Open a pull request whose description you write yourself, with a suggested title and a light proofread.
argument-hint: "[--auto [--screenshots <url>...]] [base branch, optional]"
---

# PR

The LLM wrote the commits. The user owns the feature, so the user writes the
description. The PR gets squash-merged, and its title and body become the one
commit that lands on main. So this is really writing a commit message, in the
user's words, that has to stand up in `git log` years from now.

Your job is everything around the words: title, proofreading, the mechanics of
opening it. The failure to avoid is drafting the description yourself. Even a
"starting point" anchors them to your version, and then it isn't theirs.

```
recon --> brief + title --> user writes --> proof --> sign-off --> open
                             ^                        |
                             +------ changes ---------+
```

Arguments start with `--auto`? Nobody will write or approve the description.
Read [Autonomous mode](#autonomous-mode) first; it replaces steps 2 through 6.

## 1. Recon

Base branch is `$ARGUMENTS` (minus `--auto` and `--screenshots`), or the repo default (`gh repo view --json
defaultBranchRef`, falling back to `main`).

Read, don't ask:

- `git status`. Uncommitted changes or sitting on the base branch: stop and say
  so. Committing and branching are other jobs.
- `git log <base>..HEAD` and `git diff <base>...HEAD --stat`. What the branch
  does, so you can title it and later check their description against it.
- House style: `gh pr list --state merged --limit 15 --json title,body`, plus
  `git log <base> --oneline -20` for repos without `gh` history. Look at mood
  ("Add" vs "Added"), prefixes (`feat:`, `[JIRA-123]`), capitalization, how code
  names are marked (backticks?), length, and where bodies put issue links.
- PR template: `pull_request_template.md`, any case, in `.github/`, the repo
  root, or `docs/`. A `.github/PULL_REQUEST_TEMPLATE/` folder holds several;
  pick the one that fits the branch.
- The issue the branch works on: a number or issue URL in the branch name
  (`42-shipping-emails`, `issue-42`), the commits, or a SPEC the branch adds
  or names. Only what those say; don't search the tracker for a match.

If `gh` isn't available, say which checks you skipped and carry on with git.

## 2. Brief them

The user didn't write this code, and they're about to put their name on a
description of it. Before they write, give them a fast read of what they're
describing — a two-minute version of `/diff-explainer`, in chat, no artifact.

Start from the commits: subjects and bodies are the cheapest source, and the
LLM that wrote them often left its reasoning there. Then skim `git diff
<base>...HEAD` to check the commits against the code and find what they left
out. Skip generated files and lockfiles.

Three short groups, fragments not sentences, a handful of bullets total:

- **Changed** — behavior, not files. "Guests can check out without an
  account; orders store an email instead of a user," not "edited
  `orders_controller.rb`."
- **Risks** — what could break or bite later. A test that asserts nothing, a
  callback that now fires on every save, a query that grows with the table, a
  deploy-order problem (code that reads a column before the migration runs).
- **Tradeoffs** — the choices the code made, and the obvious alternative it
  didn't take. Polling over webhooks, a JSON column over a join table.

Only what the code or commits show. Don't guess at why; a wrong reason is
worse than none, because the user may repeat it in the description. Leave a
group out if there's nothing real to put in it. A trivial branch (a copy
change, a version bump) gets one line.

Keep it as notes, not paragraphs. Prose here turns into their description.

## 3. Suggest a title, ask for the description

Same message as the brief:

- A suggested title in the house style. Imperative, under ~65 characters,
  since GitHub appends ` (#123)` and it becomes a commit subject. Name the
  observable change, not the mechanism. Offer one alternate at most.
- Ask them to write the description. Mention the useful questions a squash
  commit should answer, briefly: why this change, why this way, anything a
  future reader would trip on.
- A PR template? Name its headings, so they write into it.
- An issue? Remind them to link it (`Closes #42`) so it closes on merge.

Then stop and wait. Don't draft a description, a template, or an example.

If they hand back notes or fragments and say "clean this up", that's their
content, so turning it into sentences is fine. If they ask you to write it from
scratch, remind them once that the skill exists so the description is theirs,
then do what they say.

## 4. Proof

Fix what's wrong, leave what's theirs. Wrong means typos, grammar, broken
markdown, unclear sentences, a code name that should be in backticks. Theirs
means word choice, tone, structure, length, opinions, humor. A proofread that
reads like you wrote it has failed, even if every sentence got "better".

Also:

- **Check claims against the diff.** "Emails the customer a receipt" with
  no mailer in the diff is a problem. Flag it; don't fix it. They may know
  something the diff doesn't show, or the branch may be missing a commit.
- **Wrap prose at 72 columns.** It becomes a commit body. Leave code blocks,
  tables, and URLs alone.
- **Don't add sections, headers, summaries, or a closing line.**
- **Don't add attribution.** No co-author trailer, since GitHub copies the
  branch commits' trailers into the squash commit already. No "Generated with"
  line either; the description isn't generated.

If it's already clean, say so and change nothing. Churn on good prose is the
opposite of help.

## 5. Sign-off

Show:

- What you changed, as a short list (`teh` → `the`, wrapped lines, backticked
  `User#email`). Not a diff of every line.
- Anything you flagged and didn't change.
- The final title and body exactly as they'll be sent, in a fenced block.

Ask for a yes. Any edit they request, apply it and show the full final version
again. The yes has to be to the exact text that goes out; approving "the title
change" isn't approving the body you haven't re-shown.

## 6. Open

Only after a yes to the text you last showed.

Push if the branch has no upstream (`git push -u origin HEAD`). Write the body
to a temp file and pass it with `--body-file`, so backticks and newlines
survive the shell:

```
gh pr create --base <base> --title "<title>" --body-file <tmpfile>
```

Reply with the PR URL.

## Autonomous mode

Only when the arguments start with `--auto`. Nobody is there: a human finds
the draft PR later, rewrites the description, and marks it ready. Without
`--auto`, ignore this section.

You write the description, since nobody else will. It does
`/diff-explainer`'s job as a PR: the why, not the what. Read its steps 3 and 4
(`../diff-explainer/SKILL.md`) for what earns a note and the rule against
inventing rationale. Short beats thorough; a reviewer skims a long PR.

- **Recon as in step 1.** Uncommitted changes or on the base branch: stop, and
  make the reply say why.
- **Gather the why.** Commit bodies, then a SPEC the branch adds or names,
  then the diff. A reason none of them state is "not recorded", never a guess.
- **Body: plain English.** Write it for someone who uses the product but
  never reads the code, like the support lead. What changed for the people
  using it, and why. No file paths, commit SHAs, code names, or jargon;
  those belong in the notes. Wrap at 72.
  - Bad: "Adds a PDF format to `InvoicesController#show` (a3e96d0)."
  - Good: "Support resends old invoices by hand a few times a week. Now
    customers can download them as PDFs."
- **Write the body and notes in thoughtbot's voice.** See [Voice](#voice).
- **Notes go on the lines.** Each risk, tradeoff, or open question becomes an
  inline comment on the line it's about, starting `**Risk:**`,
  `**Tradeoff:**`, or `**Open question:**`. One to two sentences, for the
  engineer. Most branches get two to four; a typo fix gets none.
- **Then say each note plainly.** A short paragraph under it for someone
  who's never read code, written the way `/eli5` explains (steps 3 and 4 of
  `../eli5/SKILL.md`): what happens to a person, then one everyday analogy.
  No code names or programmer words like job or callback. When order or
  flow is the point, add a small drawing in a code block, under 60
  characters wide, since GitHub's comment column is narrow. Real values
  from the branch only; no drawing beats an invented one. Read that
  skill, don't run it; it sends out agents, and this is a paragraph.
  Where the two disagree, this bullet wins: no drawing unless order
  matters, and no real name after the plain version.
- **Sign what you wrote.** The body and every note end with a line naming
  the model that wrote them, so a reader can tell AI text from a human's.
  See [Attribution](#attribution).
- **House style sets the shape.** A PR template replaces the default body
  below: keep its headings in order, fill each under these rules, and
  delete its instruction comments (`<!-- -->`). Tick a box only when the
  branch backs it. A section nothing on the branch speaks to gets "Not
  recorded." No template: lay it out like recent merged PRs. Neither: use
  the default.
- **Link the issue** recon found, on its own line: `Closes #42`
  (`owner/repo#42` for another repo), where the template or recent PRs put
  it, else last before the attribution line. `Refs #42` instead when the
  commits or SPEC say the branch does only part of it. None found: no line.
- **Screenshots only when passed in.** `--screenshots` takes image URLs the
  caller already hosted. Embed each one; don't take, upload, or commit any
  yourself. None passed: no screenshots section.
- **Have it checked.** One fresh subagent gets the body, the notes, and the
  base branch, and reads the commits and diff itself. Ask for: claims the
  diff doesn't back, a reason the commits, SPEC, and diff never give, a
  risk you missed, any note that would still be true with the diff hidden,
  and anything in the body or a note's plain paragraph a non-technical
  reader would trip on. Skip wording. Fix once. An analogy or drawing
  that's wrong gets fixed, not cut.
- **Title** as in step 3.

The default body:

````
```markdown
{what changed for the people using it, and why, one to three sentences}

{each --screenshots URL as ![](url). Leave out when none were passed.}

{Closes #N. Leave out when recon found no issue.}

{the attribution line}
```
````

A note:

````markdown
**Risk:** We charge the card before saving the `Payment`, so a failed
save leaves a charge with no record. We might want to save it first.

The customer pays, but their invoice still says unpaid, and support
has nothing to look up. It's a cashier who runs your card and then
drops the receipt in the bin.

```
card charged $40 --> saving the payment fails
                          |
                          v
     invoice still "unpaid", no payment on file
```

_Claude Opus 5.5 (claude-opus-5-5)_
````

### Attribution

Name the model from your system prompt: its name and exact ID, like
`Claude Opus 5.5 (claude-opus-5-5)`. Don't know it? Write `Claude` alone.
Never guess a model.

- **Body**, last line, its own paragraph:
  `_Written by Claude Opus 5.5 (claude-opus-5-5) with /pr --auto. No human
has edited this yet._`
- **Each note**, its own last line: `_Claude Opus 5.5 (claude-opus-5-5)_`.
  Notes show up one at a time on GitHub, so each one needs it.

This is the only attribution. No "Generated with Claude Code" line or
co-author trailer on top of it.

### Voice

The body and the notes should sound like thoughtbot, not one person.
This follows thoughtbot's [voice and tone][voice] guide.

Both:

- **"We" for the team**, at least once in the body and in each note:
  "Now we ...", "We send ...". Never "I".
- **Conversational, not academic or enterprisey.** Contractions
  ("doesn't", "we're"), easy words, short sentences. If a sentence is
  awkward to read aloud, simplify it. No sales words, and no stiff ones
  like "Consider", "Ensure", or "potential issue".
- **Serious when it matters.** A light touch is fine in the body. A
  risk stays plain: no jokes about lost data.
- **Mechanics.** Numerals ("3 retries", not "three retries"), unless
  the number starts a sentence. Oxford comma. No emoji. One exclamation point per paragraph at most; most
  need none.

The body:

- **Open with what prompted the change**, not what changed: "Now that
  ...", "Prior to this, ...", "Follow-up to #77.", or the problem in
  one sentence. Pick what fits.
- **Then what changed**, a sentence or two.
- **Caveats get their own short paragraph**: "For the time being, ...",
  "Note that ...".
- **Short paragraphs.** No headings or bold. Bullets only for a list of
  rules.
- **Links go at the bottom**, reference-style: `this [discussion][1]`,
  then `[1]: https://...`.

```markdown
Prior to this, support resent old invoices by hand a few times a week.

Now customers can download any past invoice as a PDF, so we can stop
resending them.

For the time being, invoices from before 2020 aren't included.
```

The notes, like a teammate's review comment:

- **Two sentences, no more.** What we do and why, with "since" or
  "because". Then a suggestion, not an order: "We might want ...",
  "This feels like a separate PR." An open question ends on its
  question instead. Cut detail to fit; the plain
  paragraph covers who it hurts.
  "We retry every failed charge, since `rescue` catches all errors. We
  might want to rescue only `CardDeclined`."
- **Ask with a case**, when a case makes the question: "What happens if
  we pass an empty cart?", then the call that shows it, with real
  values, in a code block. The block doesn't count as a sentence.
- **Say when it can wait**, only when the branch backs it: "That's OK
  for now, since nothing calls it yet."

Only the voice. Every claim still comes from the branch.

[voice]: https://thoughtbot.com/playbook/the-thoughtbot-way/brand/voice-and-tone

### Open it

Push (`git push -u origin HEAD`), whatever the host: the remote needs every
commit before anyone can open or review a PR from it. Then, on GitHub with
`gh`:

```bash
gh pr create --draft --base <base> --title "<title>" --body-file <tmpfile>
```

Inline notes go up as one review, so the PR gets one notification, not ten:

```bash
gh api repos/{owner}/{repo}/pulls/<n>/reviews --input review.json
# {"event": "COMMENT", "commit_id": "<head sha>", "comments": [
#   {"path": "app/models/order.rb", "line": 4, "side": "RIGHT",
#    "body": "**Risk:** ...\n\n{plain paragraph}\n\n_Claude Opus 5.5 (claude-opus-5-5)_"}]}
```

`line` has to be a line in the diff, numbered in the new file.

Not GitHub, no CLI, or a call fails: don't look for a workaround. The reply
is the handoff.

The reply: the PR URL, or why it wasn't opened plus the title and body in a
fenced block. Any notes that didn't get posted go there too, as `path:line`
bullets with their attribution line, ready to paste. Fence each note with
`~~~`, so a drawing's ``` doesn't close it early. Then what the check changed, one line each.
