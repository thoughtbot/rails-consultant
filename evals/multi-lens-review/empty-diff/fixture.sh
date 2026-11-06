#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

bash "$(dirname "$0")/../rails-app.sh"

mkdir -p docs/specs

cat > docs/specs/project-due-dates.md <<'MD'
# Project due dates

Owners can give a project a due date and see it on the projects list.

## Acceptance criteria

- [ ] Given I'm editing a project, when I set a due date and save, then I see that date on the project's page.
- [ ] Given a project has a due date, when I view my projects list, then I see the date next to its name.
MD

git add -A
git commit -q -m "Add SPEC for project due dates"

git remote add origin git@github.com:acme/tracker.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

git checkout -q -b project-due-dates
