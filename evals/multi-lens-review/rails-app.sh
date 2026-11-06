#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

git init -q -b main
git config user.name "Eval User"
git config user.email "eval@example.com"
git config commit.gpgsign false
git config core.excludesFile /dev/null

mkdir -p app/controllers app/models app/mailers app/views/projects config db test/controllers test/fixtures

cat > Gemfile <<'RUBY'
source "https://rubygems.org"

gem "rails", "~> 7.1"
gem "pg"
RUBY

cat > config/application.rb <<'RUBY'
require_relative "boot"
require "rails/all"

module Tracker
  class Application < Rails::Application
    config.load_defaults 7.1
  end
end
RUBY

cat > config/routes.rb <<'RUBY'
Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :projects
  root "projects#index"
end
RUBY

cat > db/schema.rb <<'RUBY'
ActiveRecord::Schema[7.1].define(version: 2026_09_01_120000) do
  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.timestamps
  end

  create_table "projects", force: :cascade do |t|
    t.references "user", null: false, foreign_key: true
    t.string "name", null: false
    t.text "description"
    t.timestamps
  end
end
RUBY

cat > app/models/user.rb <<'RUBY'
class User < ApplicationRecord
  has_secure_password
  has_many :projects, dependent: :destroy
end
RUBY

cat > app/models/project.rb <<'RUBY'
class Project < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
end
RUBY

cat > app/mailers/application_mailer.rb <<'RUBY'
class ApplicationMailer < ActionMailer::Base
  default from: "tracker@example.com"
  layout "mailer"
end
RUBY

cat > app/controllers/application_controller.rb <<'RUBY'
class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    redirect_to new_session_path unless current_user
  end
end
RUBY

cat > app/controllers/projects_controller.rb <<'RUBY'
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = current_user.projects.order(:name)
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
<h1>Projects</h1>

<ul>
  <% @projects.each do |project| %>
    <li><%= link_to project.name, project %></li>
  <% end %>
</ul>

<%= link_to "New project", new_project_path %>
ERB

cat > app/views/projects/show.html.erb <<'ERB'
<h1><%= @project.name %></h1>

<p><%= @project.description %></p>

<%= link_to "Edit", edit_project_path(@project) %>
<%= button_to "Delete", @project, method: :delete %>
ERB

cat > test/test_helper.rb <<'RUBY'
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post session_path, params: { email: user.email, password: "password" }
  end
end
RUBY

cat > test/fixtures/users.yml <<'YAML'
alice:
  email: alice@example.com
  password_digest: <%= BCrypt::Password.create("password") %>

bob:
  email: bob@example.com
  password_digest: <%= BCrypt::Password.create("password") %>
YAML

cat > test/fixtures/projects.yml <<'YAML'
website:
  user: alice
  name: Website

mobile_app:
  user: bob
  name: Mobile app
YAML

cat > test/controllers/projects_controller_test.rb <<'RUBY'
require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "lists only my projects" do
    sign_in_as users(:alice)

    get projects_path

    assert_select "li", text: "Website"
    assert_select "li", text: "Mobile app", count: 0
  end

  test "can't see someone else's project" do
    sign_in_as users(:alice)

    get project_path(projects(:mobile_app))

    assert_response :not_found
  end
end
RUBY

git add -A
git commit -q -m "Initial app"
