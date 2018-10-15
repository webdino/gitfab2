require 'rake'

describe 'rake task backup' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('backup', ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
  end

  describe 'backup:delete' do
    before do
      FileUtils.mkdir_p(Rails.root.join('tmp', 'spec', 'zip'))
      File.open(Rails.root.join('tmp', 'spec', 'zip', 'example.zip'), 'w')
      @rake['backup:delete'].reenable
    end

    describe '3 days later' do
      around do |example|
        travel_to(3.days.since) { example.run }
      end

      it do
        @rake['backup:delete'].invoke(Rails.root.join('tmp', 'spec', 'zip'))
        expect(File.exist?(Rails.root.join('tmp', 'spec', 'zip', 'example.zip'))).to eq false
      end
    end

    describe '2 days later' do
      around do |example|
        travel_to(2.days.since) { example.run }
      end

      it do
        @rake['backup:delete'].invoke(Rails.root.join('tmp', 'spec', 'zip'))
        expect(File.exist?(Rails.root.join('tmp', 'spec', 'zip', 'example.zip'))).to eq true
      end
    end

    after do
      FileUtils.rm_rf(Rails.root.join('tmp', 'spec'))
    end
  end
end
