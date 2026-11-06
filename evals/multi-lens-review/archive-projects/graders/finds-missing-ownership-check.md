---
type: llm
---

This is a code review of a branch. In `app/controllers/projects_controller.rb`, the new `archive` action loads the project with `Project.find(params[:id])`. Every other action loads it with `current_user.projects.find(params[:id])`.

PASS if the review says `archive` doesn't check that the project belongs to the signed-in user, so one user can archive another user's project.

FAIL if the review doesn't report that.
