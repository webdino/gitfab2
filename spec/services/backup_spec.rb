# frozen_string_literal: true

describe Backup do
  describe '.delete_old_files' do
    subject { Backup.delete_old_files }

    before do
      FileUtils.mkdir_p(Rails.root.join('tmp', 'backup', 'zip'))
      File.open(Rails.root.join('tmp', 'backup', 'zip', 'example.zip'), 'w')
    end

    describe '3 days later' do
      around do |example|
        travel_to(3.days.since) { example.run }
      end

      it do
        subject
        expect(File.exist?(Rails.root.join('tmp', 'backup', 'zip', 'example.zip'))).to eq false
      end
    end

    describe '2 days later' do
      around do |example|
        travel_to(2.days.since) { example.run }
      end

      it do
        subject
        expect(File.exist?(Rails.root.join('tmp', 'backup', 'zip', 'example.zip'))).to eq true
      end
    end

    after do
      FileUtils.rm_rf(Rails.root.join('tmp', 'backup', 'zip', 'example.zip'))
    end
  end
end
