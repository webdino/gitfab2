load "deploy/assets"
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"

set :application, "gitfab2"
set :repository, "https://github.com/mozilla-japan/gitfab2.git"
set :scm, :git

set :rvm_ruby_string, "ruby-2.1.0"
set :rvm_type, :system
set :rvm_path, "/usr/local/rvm"

set :user, "deploy"
set :use_sudo, false
set :default_run_options, pty: true

set :current_rev, `git show --format='%H' -s`.chomp
set :branch do
  default_tag = current_rev
  tag = ENV["DEPLOY_TARGET"] || Capistrano::CLI.ui.ask("Tag to deploy ->: [#{default_tag}]")
  tag = default_tag if tag.empty?
  tag
end

namespace :deploy do
  task :restart, roles: :web, except: {no_release: true} do
    if File.exist? "#{pid_file}"
      run "kill -USR2 `cat #{pid_file}`"
    end
  end
end

set :keep_releases, 2
after "deploy:restart", "deploy:cleanup"
