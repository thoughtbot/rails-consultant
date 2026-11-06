#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

mkdir -p lib/greeter

cat > lib/greeter/version.rb <<'RUBY'
module Greeter
  VERSION = "1.4.2"
end
RUBY

cat > lib/greeter.rb <<'RUBY'
require_relative "greeter/version"

module Greeter
  def self.hello(name)
    "Hello, #{name}!"
  end
end
RUBY

git add -A
git commit -q -m "Initial gem"

git checkout -q -b release-1.4.3
sed -i.bak 's/1\.4\.2/1.4.3/' lib/greeter/version.rb && rm lib/greeter/version.rb.bak
git add -A
git commit -q -m "Bump version to 1.4.3"
