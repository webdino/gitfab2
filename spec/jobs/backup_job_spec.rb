RSpec.describe BackupJob, type: :job do
  subject { described_class.perform_later(user) }

  let!(:user) { FactoryBot.create(:user) }
  it { expect{ subject }.to have_enqueued_job(described_class).with(user).on_queue('default') }

  describe 'running backup and mailer' do
    it do
      expect_any_instance_of(Backup).to receive(:create)
      expect(UserMailer).to receive_message_chain(:backup, :deliver_now)
      perform_enqueued_jobs { subject }
    end
  end
end
