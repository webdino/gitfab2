require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/clockwork"
Dir.glob("lib/capistrano/tasks/*.cap").map &:import
set :clockwork_file, "lib/tasks/extract_tags_on_clock.rb"
