#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

bash "$(dirname "$0")/../rails-app.sh"

mkdir -p docs/specs

cat > docs/specs/archive-projects.md <<'MD'
# Archive projects

Owners can archive a project they're done with, so it drops off their
projects list without being deleted.

## Job story

When my projects list fills up with finished work
I want to put old projects away without deleting them
So I can find the ones I'm working on

## Acceptance criteria

- [ ] Given I own an active project, when I click "Archive" on its page, then I land on my projects list and that project isn't in it.
- [ ] Given I have an archived project, when I click "Archived" on my projects list, then I see that project listed.
MD

git add -A
git commit -q -m "Add SPEC for archiving projects"

git remote add origin git@github.com:acme/tracker.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

git checkout -q -b archive-projects

mkdir -p db/migrate

cat > db/migrate/20261027140000_add_archived_at_to_projects.rb <<'RUBY'
class AddArchivedAtToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :archived_at, :datetime
  end
end
RUBY

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[7.1].define(version: 2026_10_27_140000) do
  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.timestamps
  end

  create_table "projects", force: :cascade do |t|
    t.references "user", null: false, foreign_key: true
    t.string "name", null: false
    t.text "description"
    t.datetime "archived_at"
    t.timestamps
  end
end
RUBY

cat > app/models/project.rb <<'RUBY'
class Project < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archive!
    update!(archived_at: Time.current)
  end
end
RUBY

git add -A
git commit -q -m "Add archived_at to projects"

cat > config/routes.rb <<'RUBY'
Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :projects do
    member do
      patch :archive
    end
  end
  root "projects#index"
end
RUBY

cat > app/controllers/projects_controller.rb <<'RUBY'
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = current_user.projects.active.order(:name)
  end

  def show
  end

  def new
    @project = current_user.projects.new
  end

  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  def archive
    project = Project.find(params[:id])
    project.archive!
    ProjectMailer.archived(project).deliver_later
    redirect_to projects_path, notice: "Project archived."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
RUBY

mkdir -p app/views/project_mailer

cat > app/mailers/project_mailer.rb <<'RUBY'
class ProjectMailer < ApplicationMailer
  def archived(project)
    @project = project
    mail to: project.user.email, subject: "#{project.name} was archived"
  end
end
RUBY

cat > app/views/project_mailer/archived.text.erb <<'ERB'
Your project <%= @project.name %> was archived on <%= @project.archived_at.to_date %>.

It no longer shows on your projects list.
ERB

cat > app/views/projects/show.html.erb <<'ERB'
<h1><%= @project.name %></h1>

<p><%= @project.description %></p>

<%= link_to "Edit", edit_project_path(@project) %>
<%= button_to "Archive", archive_project_path(@project), method: :patch %>
<%= button_to "Delete", @project, method: :delete %>
ERB

cat >> test/controllers/projects_controller_test.rb <<'RUBY'

class ArchiveProjectTest < ActionDispatch::IntegrationTest
  test "archiving a project takes it off my list" do
    sign_in_as users(:alice)

    patch archive_project_path(projects(:website))

    assert_redirected_to projects_path
    follow_redirect!
    assert_select "li", text: "Website", count: 0
  end
end
RUBY

git add -A
git commit -q -m "Archive a project from its page"

cat > app/controllers/projects_controller.rb <<'RUBY'
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    scope = params[:archived] ? current_user.projects.archived : current_user.projects.active
    @projects = scope.order(:name)
  end

  def show
  end

  def new
    @project = current_user.projects.new
  end

  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  def archive
    project = Project.find(params[:id])
    project.archive!
    ProjectMailer.archived(project).deliver_later
    redirect_to projects_path, notice: "Project archived."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
RUBY

cat > app/views/projects/index.html.erb <<'ERB'
<h1><%= params[:archived] ? "Archived projects" : "Projects" %></h1>

<ul>
  <% @projects.each do |project| %>
    <li><%= link_to project.name, project %></li>
  <% end %>
</ul>

<%= link_to "New project", new_project_path %>
<%= link_to "Archived", projects_path(archived: true) %>
ERB

cat >> test/controllers/projects_controller_test.rb <<'RUBY'

class ArchivedProjectsListTest < ActionDispatch::IntegrationTest
  test "archived projects show on the archived list" do
    projects(:website).archive!
    sign_in_as users(:alice)

    get projects_path(archived: true)

    assert_select "li", text: "Website"
  end
end
RUBY

git add -A
git commit -q -m "List archived projects"
