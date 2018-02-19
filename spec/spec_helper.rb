ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_rewinder'

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '.bundle/'
end
Coveralls.wear!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseRewinder.strategy = :transaction
    DatabaseRewinder.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseRewinder.strategy = :transaction
    DatabaseRewinder.start
  end

  config.before(:each, use_truncation: true) do
    DatabaseRewinder.strategy = :truncation
    DatabaseRewinder.start
  end

  config.after(:each) do
    DatabaseRewinder.clean
  end

  config.after(:all) do
    DatabaseRewinder.clean_with(:truncation)
  end
end

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ControllerMacros::InstanceMethods, :type => :controller

  config.before(:all) do
    FactoryGirl.reload
  end
end
