source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '4.2.10'

gem 'acts_as_list'
gem 'after_commit_action'
gem 'cancancan'
gem 'carrierwave'
gem 'delayed_job_active_record'
gem 'devise'
gem 'exception_notification'
gem 'friendly_id'
gem 'jbuilder'
gem 'kaminari'
gem 'mini_magick'
gem 'nested_form'
gem 'nokogiri'
gem 'omniauth-github'
gem 'rails_autolink'
gem 'ransack'
gem 'sanitize'
gem 'slack-notifier'
gem 'slim-rails'
gem 'stl', github: 'oshimaryo/stl-ruby'
gem 'stl2gif', github: 'oshimaryo/stl2gif', branch: 'develop', ref: '2e508559aa3e2e5f935214d2e6988f1862cea26f'
gem 'truncate_html'
gem 'unicorn'

# DB
gem 'mysql2', '~> 0.3.21'
gem 'ridgepole'

# Frontend
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'mini_racer'
gem 'sass-rails'
gem 'uglifier'

group :development, :test do
  gem 'better_errors'
  gem 'bullet'
  gem 'coveralls', require: false
  gem 'delayed_job_web'
  gem 'factory_bot_rails'
  gem 'rack-mini-profiler'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'slim_lint'
  gem 'simplecov', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'meta_request'
  gem 'web-console'

  # Deploy
  gem 'capistrano', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
end

group :test do
  gem 'database_rewinder'
end

