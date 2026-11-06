#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../implement-with-tdd/billing-app.sh"

branch_off() {
  git init -q --bare .origin.git
  echo .origin.git >> .git/info/exclude
  git remote add origin "$PWD/.origin.git"
  git push -q origin main
  git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  git checkout -q -b "$1"
}
