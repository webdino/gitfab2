pid_file = '/tmp/unicorn_gitfab2.pid'

set :application, 'gitfab2'
set :repo_url, 'https://github.com/webdino/gitfab2.git'
set :rvm_type, :system
set :rvm_ruby_version, '2.3.5'
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

# set :delayed_job_roles, [:app]

### Set the location of the delayed_job logfile
# set :delayed_log_dir, '/usr/local/rails_apps/gitfab2/shared/log'

# namespace :delayed_job do
#   desc "Install Deployed Job executable if needed"
#   task :install do
#     on roles(delayed_job_roles) do |host|
#       within release_path do
#         # Only install if not already present
#         unless test("[ -f #{release_path}/#{delayed_job_bin} ]")
#           with rails_env: fetch(:rails_env) do
#             execute :bundle, :exec, :rails, :generate, :delayed_job
#           end
#         end
#       end
#     end
#   end
#
#   before :start, :install
#   before :restart, :install
# end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute "kill -USR2 `cat #{pid_file}`" if File.exist? "#{pid_file}"
    end
  end

  after :publishing, :restart
end
