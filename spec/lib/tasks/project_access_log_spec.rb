require 'rake'

describe 'project_access_log' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('project_access_log', ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
  end

  describe 'project_access_log:log_from_csv' do
    subject { @rake['project_access_log:log_from_csv'].invoke(csv_path) }
    let(:csv_path) { Rails.root.join('tmp', 'log_csv_test.csv') }

    before do
      FactoryBot.create(:user_project, name: 'hoge',owner: FactoryBot.create(:user, name: 'owner1'))
      FactoryBot.create(:user_project, name: 'hoge',owner: FactoryBot.create(:user, name: 'owner2'))
      rows = <<~ROWS
          /owner1/hoge,2
          /owner2/hoge,2
          /owner3,2

      ROWS

      File.write(csv_path, rows, mode: 'w')
      @rake['project_access_log:log_from_csv'].reenable
    end

    after { FileUtils.rm(csv_path, force: true) }

    it do
      expect{ subject }.to change{ ProjectAccessLog.count }.from(0).to(4)
    end
  end
end
