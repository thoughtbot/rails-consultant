#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../shop-app.sh"

git init -q --bare .origin.git
echo .origin.git >> .git/info/exclude
git remote set-url origin "$PWD/.origin.git"
git push -q origin main
