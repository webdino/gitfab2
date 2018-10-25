# frozen_string_literal: true

describe Backup do
  describe '.delete_old_files' do
    subject { Backup.delete_old_files }
    let(:zip_path) { Rails.root.join('tmp', 'backup', 'zip', 'example.zip') }

    before do
      Rails.root.join('tmp', 'backup', 'zip').mkpath
      File.open(zip_path, 'w')
    end

    describe '3 days later' do
      around do |example|
        travel_to(3.days.since) { example.run }
      end

      it do
        subject
        expect(zip_path.exist?).to eq false
      end
    end

    describe '2 days later' do
      around do |example|
        travel_to(2.days.since) { example.run }
      end

      it do
        subject
        expect(zip_path.exist?).to eq true
      end
    end
  end

  after(:each) do
    FileUtils.rm(zip_path, force: true)
  end
end
