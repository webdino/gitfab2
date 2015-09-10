pid_file = '/tmp/unicorn_gitfab2.pid'

lock '3.1.0'

set :application, 'gitfab2'
set :repo_url, 'https://github.com/mozilla-japan/gitfab2.git'
set :rvm_type, :system
set :rvm_ruby_version, '2.1.2'
set :assets_roles, [:web, :app]

if ENV['DEPLOY_BRANCH']
  set :branch, ENV['DEPLOY_BRANCH']
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/usr/local/rails_apps/gitfab2'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w(log public/uploads)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 2

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute "kill -USR2 `cat #{pid_file}`" if File.exist? "#{pid_file}"
    end
  end

  after :publishing, :restart
end
