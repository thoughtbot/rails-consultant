#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../gym-app.sh"

mkdir -p docs/notes
cat > docs/notes/floor-staff-call.md <<'MD'
call w/ floor staff re belay checks, tues

Dana: so anyone who wants to rope climb has to pass a belay check first. we watch them belay, catch a fall, lower.
Marco: pass = they get a green tag on their harness. green tag means top rope only.
Dana: orange tag is lead. separate test, you need a green tag for 30 days first
Marco: if we see someone belaying sketchy on the floor we pull their tag. on the spot. no argument
Dana: then they have to retest, but not same day. next day earliest
Marco: kids under 14 can't get a tag at all, they climb with a parent who has one
Dana: oh and if someone comes in with a tag from another gym we still make them do a check. we don't honor outside tags
Marco: sometimes we just do a quick re-up instead of a full retest if it was something small. depends who's on
Dana: the re-up thing isn't written down anywhere tbh
MD

commit "Add notes from floor staff call"
