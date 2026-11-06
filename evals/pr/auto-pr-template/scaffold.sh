#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../shop-app.sh"

git checkout -q main
mkdir -p .github
cat > .github/pull_request_template.md <<'MD'
## Why

<!-- What problem does this solve for customers or staff? -->

## How to check it

<!-- Steps a reviewer can follow on staging. -->

## Checklist

- [ ] Tests cover the change
- [ ] Help center article updated
MD
commit -m "Add a PR template"
git checkout -q shipping-emails
git rebase -q main

git init -q --bare .origin.git
echo .origin.git >> .git/info/exclude
git remote set-url origin "$PWD/.origin.git"
git push -q origin main
