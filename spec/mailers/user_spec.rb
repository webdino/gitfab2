RSpec.describe UserMailer, type: :mailer do
  describe "#reset_password_instructions" do
    let(:mail) { UserMailer.reset_password_instructions(email, token) }
    let(:email) { "test@example.com" }
    let(:token) { "reset_token" }

    it "renders the headers" do
      expect(mail.subject).to eq("Reset password instructions")
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(["support@fabble.cc"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hello #{email}")
                              .and include("/password/edit?reset_password_token=#{token}")
    end
  end

  describe '#backup' do
    let(:mail) { UserMailer.backup(user) }
    let(:user) { FactoryBot.create(:user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Download your backup')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['support@fabble.cc'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Hello #{user.name}")
                              .and include("user/edit#download-backup")

    end
  end
end
