---
name: risk-score
description: Score how risky a pull request or branch is with fixed rules, and reply with the result as JSON. Use when asked how risky a PR, branch, or diff is, or to gate CI on PR risk.
argument-hint: "[PR number or URL | base branch]"
---

# Risk score

This runs in CI, where something reads the JSON and decides whether a PR needs
a second reviewer or can merge. That only works if the same diff gets the same
score every time. So the score comes from `scripts/score.py`, never from you.

Your job is getting the right diff into the script and handing back what it
prints, untouched. If a rule looks wrong for this PR, that's a change to the
script, made in a PR of its own. Bending one score breaks the thing CI trusts.

## 1. Pick the diff

`$ARGUMENTS` decides:

- A number, or a GitHub PR URL: the PR.

  ```bash
  gh pr diff <number or url> --color=never
  ```

- Anything else non-empty: a base branch to compare the current branch with.
- Empty: the base is `origin/$GITHUB_BASE_REF` when that's set (GitHub Actions
  sets it on `pull_request` runs), else what `git symbolic-ref --short
refs/remotes/origin/HEAD` prints, else `main`.

  ```bash
  git -c core.quotePath=false diff --no-color --no-ext-diff --find-renames <base>...HEAD
  ```

The flags pin the output format, so a user's git config can't change the
score. Three dots means the diff since the branch left the base, which is what
a PR shows. Uncommitted changes aren't part of a PR, so they aren't scored.

## 2. Score it

Pipe the diff straight in. Don't save, trim, or filter it first; the script
already skips lockfiles and generated files where they shouldn't count.

```bash
git ... | python3 <this skill's directory>/scripts/score.py
```

The script reads only the diff, never git history, so a shallow CI checkout
works as long as the diff command does.

## 3. Reply

Reply with exactly what the script printed: one JSON object, no code fence,
nothing before or after. Something like `jq` parses your reply, so a sentence
of commentary breaks the job that called you.

```json
{
  "score": 7,
  "level": "high",
  "files_changed": 3,
  "lines_changed": 41,
  "signals": [
    {
      "rule": "migration",
      "points": 2,
      "reason": "Changes the database schema",
      "files": ["migrations/20261103_drop_legacy_status.js"]
    },
    {
      "rule": "destructive_migration",
      "points": 3,
      "reason": "Drops, renames, or rewrites existing columns, tables, or rows",
      "files": ["migrations/20261103_drop_legacy_status.js"]
    },
    {
      "rule": "untested_code",
      "points": 2,
      "reason": "Changes code without changing any tests",
      "files": ["src/orders.js"]
    }
  ]
}
```

That holds when the user calls the change small, safe, or urgent, too. Their
read of the PR isn't an input to the score.

If the diff command fails, reply with one JSON object instead, and still
nothing else:

```json
{
  "error": "git diff origin/main...HEAD failed: no merge base",
  "hint": "Check out with fetch-depth: 0, or pass the PR number."
}
```

Use the command's own error message. "No merge base" in CI almost always
means a shallow checkout; the hint above is the fix. Never score a different
diff than the one asked for to get around an error.

## Rules

For reading results, not for scoring by hand. Levels: 0–2 low, 3–5 medium, 6+
high.

| Rule                    | Points    | Fires when                                                                                                                               |
| ----------------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `large_diff`            | 1 / 2 / 3 | 50 / 200 / 500+ lines changed, lockfiles, vendored, and generated files excluded                                                         |
| `many_files`            | 1 / 2     | 10 / 25+ files changed                                                                                                                   |
| `migration`             | 2         | A file in a migrations folder (Rails, Django, Laravel, Knex, Ecto, EF Core, Flyway, Liquibase, Alembic, Prisma) or a `.sql` file changes |
| `destructive_migration` | 3         | A migration adds a drop, rename, column change, truncate, or delete, in any of those tools' syntax or plain SQL                          |
| `sensitive_path`        | 3         | A code file's path names auth, sessions, passwords, permissions, secrets, or payments                                                    |
| `dependencies`          | 2         | A manifest or lockfile changes (`package.json`, `go.mod`, `pyproject.toml`, `Gemfile`, `*.csproj`, ...)                                  |
| `infra_config`          | 2         | CI, Docker, Terraform, `.env`, or app config changes (`config/`, `settings.py`, `application.yml`, `appsettings.json`)                   |
| `untested_code`         | 2         | Code changes and no test file does                                                                                                       |
| `tests_removed`         | 2         | Test files lose more lines than they gain                                                                                                |
