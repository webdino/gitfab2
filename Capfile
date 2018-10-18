require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/rvm"
require "capistrano/npm"
require "capistrano/rails"
require "capistrano/scm/git"
require "capistrano/delayed_job"
require "whenever/capistrano"
install_plugin Capistrano::SCM::Git
Dir.glob("lib/capistrano/tasks/*.rake").each{ |task| import(task) }
