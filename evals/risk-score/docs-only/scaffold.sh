#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../store-app.sh"

git checkout -q -b fix-readme-typo
sed -i.bak 's/reciepts/receipts/' README.md && rm README.md.bak
commit -m "Fix typo in README"
