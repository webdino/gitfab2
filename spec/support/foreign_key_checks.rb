RSpec.configure do |config|
  config.before(:each, foreign_key_checks: false) do
    ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
  end

  config.after(:each, foreign_key_checks: false) do
    ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
  end
end
