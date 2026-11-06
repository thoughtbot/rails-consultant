#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null
commit() { git add -A && git commit -q -m "$1"; }

mkdir -p app/models

cat > README.md <<'MD'
# Crux

Members app for Crux Climbing. Run the tests with `bin/rails test`.
MD

cat > app/models/application_record.rb <<'RUBY'
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
RUBY

commit "Set up the members app"

cat > app/models/member.rb <<'RUBY'
class Member < ApplicationRecord
  has_one :membership
  has_many :visits
  has_many :onboarding_calls
end
RUBY

cat > app/models/membership.rb <<'RUBY'
class Membership < ApplicationRecord
  belongs_to :member
  enum :status, { active: 0, on_hold: 1, expired: 2 }

  def expire!
    update!(status: :expired, fob_enabled: false)
  end

  def hold!(until_on)
    update!(status: :on_hold, held_until: until_on, fob_enabled: false)
  end

  def reinstate!
    update!(status: :active, held_until: nil, fob_enabled: true)
  end
end
RUBY

commit "Add members and memberships"

cat > app/models/visit.rb <<'RUBY'
class Visit < ApplicationRecord
  belongs_to :member
end
RUBY

cat > app/models/onboarding_call.rb <<'RUBY'
class OnboardingCall < ApplicationRecord
  belongs_to :member
  belongs_to :coach, class_name: "Member"
end
RUBY

commit "Track visits and onboarding calls"
