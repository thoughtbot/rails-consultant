#!/usr/bin/env bash
set -euo pipefail

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

mkdir -p lib test

cat > README.md <<'EOF'
# Blog

A tiny blog engine. Posts recieve a URL from their title.
EOF

cat > lib/post.rb <<'EOF'
class Post
  attr_reader :title

  def initialize(title)
    @title = title
  end

  def path
    "/posts/#{title}"
  end
end
EOF

git add -A
git commit -q -m "Initial commit"

sed -i.bak 's/recieve/receive/' README.md && rm README.md.bak

cat > lib/slug.rb <<'EOF'
module Slug
  def self.slugify(text)
    text.downcase.strip.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
  end
end
EOF

cat > lib/post.rb <<'EOF'
require_relative "slug"

class Post
  attr_reader :title

  def initialize(title)
    @title = title
  end

  def path
    "/posts/#{Slug.slugify(title)}"
  end
end
EOF

cat > test/slug_test.rb <<'EOF'
require "minitest/autorun"
require_relative "../lib/slug"

class SlugTest < Minitest::Test
  def test_replaces_spaces_with_dashes
    assert_equal "hello-world", Slug.slugify("Hello World")
  end

  def test_strips_punctuation
    assert_equal "what-s-new", Slug.slugify("What's new?")
  end
end
EOF
