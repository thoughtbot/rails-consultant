#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../shop-app.sh"

mkdir -p docs/specs
cat > docs/specs/product-name-length.md <<'MD'
# Product name length

Product names under 3 characters keep slipping into the catalog ("A", "Mg") and look broken on the storefront.

## Behavior

- A product name must be at least 3 characters.
- Saving a shorter name fails with Rails' standard length error.
- Existing products are left alone until they're next edited.
MD

commit "Add product name length spec"
