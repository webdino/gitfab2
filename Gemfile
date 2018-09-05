source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.0'

gem 'active_decorator'
gem 'acts_as_list'
gem 'bcrypt', require: false
gem 'bootstrap'
gem 'cancancan'
gem 'carrierwave'
gem 'exception_notification'
gem 'friendly_id'
gem 'jbuilder'
gem 'kaminari'
gem 'mini_magick'
gem 'mysql2'
gem 'nested_form'
gem 'nokogiri'
gem 'omniauth-github'
gem 'rails_autolink'
gem 'sanitize'
gem 'slack-notifier'
gem 'slim-rails', github: 'slim-template/slim-rails', ref: 'a6af25b31a59f07d566bc80fa64912a9a4a05889'
gem 'sprockets-commoner'
gem 'truncate_html'
gem 'unicorn'

# Frontend
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'uglifier'

gem 'stl', github: 'oshimaryo/stl-ruby'
gem 'stl2gif', github: 'oshimaryo/stl2gif', branch: 'develop', ref: '2e508559aa3e2e5f935214d2e6988f1862cea26f'
gem 'mathn' # Used in geometry gem in stl gem

group :development, :test do
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rack-mini-profiler', require: false
  gem 'web-console'

  # Deploy
  gem 'capistrano', require: false
  gem 'capistrano-npm', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
end

group :test do
  gem 'coveralls', require: false
  gem 'database_rewinder'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

