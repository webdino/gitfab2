RSpec.describe BackupJob, type: :job do
  subject { described_class.perform_later(user) }

  let!(:user) { FactoryBot.create(:user) }
  it { expect{ subject }.to have_enqueued_job(described_class).with(user).on_queue('default') }

  describe 'running backup and mailer' do
    let(:mailer) { double('mailer') }

    before do
      allow(SecureRandom).to receive(:urlsafe_base64).and_return('securerandomtoken')
      allow(UserMailer).to receive(:backup).with(SecureRandom.urlsafe_base64, user).and_return(mailer)
    end

    it do
      expect_any_instance_of(Backup).to receive(:create)
      expect(mailer).to receive(:deliver_now)
      perform_enqueued_jobs { subject }
    end
  end
end
