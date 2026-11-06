#!/usr/bin/env bash
# Builds a tiny Ruby + sqlite3 app in the current directory. No gems, no network.
set -euo pipefail

mkdir -p bin config db lib

cat > .gitignore <<'EOF'
db/*.sqlite3
tmp/
EOF

cat > config/environment.rb <<'RUBY'
APP_ENV = ENV.fetch("APP_ENV", "development")
Dir[File.expand_path("../lib/*.rb", __dir__)].sort.each { |file| require file }
RUBY

cat > db/schema.sql <<'SQL'
CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL UNIQUE);
CREATE TABLE workspaces (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, name TEXT NOT NULL);
CREATE TABLE jobs (id INTEGER PRIMARY KEY, job TEXT NOT NULL, arg INTEGER, done INTEGER DEFAULT 0);
SQL

cat > lib/database.rb <<'RUBY'
module Database
  def self.path
    File.expand_path("../db/#{APP_ENV}.sqlite3", __dir__)
  end

  def self.execute(sql)
    out = IO.popen(["sqlite3", path, sql], &:read)
    raise "sqlite3 failed: #{sql}" unless $?.success?
    out
  end

  def self.quote(value)
    "'#{value.to_s.gsub("'", "''")}'"
  end

  def self.drop!
    File.delete(path) if File.exist?(path)
  end

  def self.setup!
    execute(File.read(File.expand_path("../db/schema.sql", __dir__)))
  end
end
RUBY

cat > lib/user.rb <<'RUBY'
class User
  attr_reader :id, :email

  def initialize(id:, email:)
    @id = id
    @email = email
  end

  def self.create(email:)
    id = Integer(Database.execute("INSERT INTO users (email) VALUES (#{Database.quote(email)}) RETURNING id;"))
    new(id: id, email: email).tap(&:after_create)
  end

  def after_create
    Workspace.provision(self)
    JobQueue.enqueue("WelcomeEmailJob", id)
  end
end
RUBY

cat > lib/workspace.rb <<'RUBY'
module Workspace
  def self.provision(user)
    name = "#{user.email.split("@").first}'s workspace"
    Integer(Database.execute("INSERT INTO workspaces (user_id, name) VALUES (#{user.id}, #{Database.quote(name)}) RETURNING id;"))
  end

  def self.for(user_id)
    Integer(Database.execute("SELECT id FROM workspaces WHERE user_id = #{Integer(user_id)} LIMIT 1;"))
  end
end
RUBY

cat > lib/job_queue.rb <<'RUBY'
module JobQueue
  def self.enqueue(job, arg)
    Database.execute("INSERT INTO jobs (job, arg) VALUES (#{Database.quote(job)}, #{Integer(arg)});")
  end

  def self.work_off
    Database.execute("SELECT id, job, arg FROM jobs WHERE done = 0 ORDER BY id;").each_line do |row|
      id, job, arg = row.chomp.split("|")
      Object.const_get(job).new.perform(Integer(arg))
      Database.execute("UPDATE jobs SET done = 1 WHERE id = #{Integer(id)};")
    end
  end
end
RUBY

cat > lib/welcome_email_job.rb <<'RUBY'
require "fileutils"

class WelcomeEmailJob
  def perform(user_id)
    email = Database.execute("SELECT email FROM users WHERE id = #{Integer(user_id)};").chomp
    dir = File.expand_path("../tmp/mail", __dir__)
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, "#{Time.now.strftime("%s%N")}-welcome.txt"), "To: #{email}\nSubject: Welcome!\n")
  end
end
RUBY

cat > lib/users_controller.rb <<'RUBY'
class UsersController
  def create(params)
    email = params.fetch(:email).strip.downcase
    return [422, "email is invalid"] unless email.match?(/\A[^@\s]+@[^@\s]+\z/)

    user = User.create(email: email)
    JobQueue.enqueue("WelcomeEmailJob", user.id)
    [302, "/workspaces/#{Workspace.for(user.id)}"]
  end
end
RUBY

cat > lib/maintenance.rb <<'RUBY'
module Maintenance
  def self.reset!
    Database.drop!
    Database.setup!
    User.create(email: "demo@example.com")
    puts "reset #{APP_ENV} database"
  end
end
RUBY

cat > bin/signup <<'RUBY'
#!/usr/bin/env ruby
require_relative "../config/environment"

status, location = UsersController.new.create(email: ARGV.fetch(0))
puts "#{status} #{location}"
RUBY

cat > bin/worker <<'RUBY'
#!/usr/bin/env ruby
require_relative "../config/environment"

JobQueue.work_off
RUBY

cat > bin/reset <<'RUBY'
#!/usr/bin/env ruby
require_relative "../config/environment"

Maintenance.reset!
RUBY

chmod +x bin/*

sqlite3 db/development.sqlite3 < db/schema.sql
sqlite3 db/development.sqlite3 "INSERT INTO users (email) VALUES ('founder@example.com'); INSERT INTO workspaces (user_id, name) VALUES (1, 'founder''s workspace');"

git init -q
git add -A
git -c user.name=Eval -c user.email=eval@example.com commit -qm "Initial app"
