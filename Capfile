require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/clockwork"
:clockwork_file = "config/clockwork.rb"
Dir.glob("lib/capistrano/tasks/*.cap").map &:import
