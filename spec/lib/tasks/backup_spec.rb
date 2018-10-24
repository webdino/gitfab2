require 'rake'

describe 'rake task backup' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('backup', ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
  end

  it do
    expect(Backup).to receive(:delete_old_files).once
    @rake['backup:delete'].invoke
  end
end
