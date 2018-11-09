# frozen_string_literal: true

describe User::PasswordAuth do
  it_behaves_like "Sign up Interface", User::PasswordAuth.new

  describe ".model_name" do
    it { expect(User::PasswordAuth.model_name).to be User.model_name }
  end

  describe "#password_auth?" do
    let(:user) { User::PasswordAuth.new }
    it { expect(user.password_auth?).to be true }
  end

  describe "#send_reset_password_instructions" do
    subject do
      user.send_reset_password_instructions(token: token, sent_at: sent_at)
    end

    let(:user) do
      FactoryBot.create(:user_password_auth,
        email: email,
        email_confirmation: email,
        reset_password_token: nil,
        reset_password_sent_at: nil
      )
    end
    let(:email) { "send_reset_password_instructions@example.com" }
    let(:token) { SecureRandom.urlsafe_base64 }
    let(:sent_at) { Time.current }

    it do
      expect(UserMailer).to receive_message_chain(:reset_password_instructions, :deliver_now)
      expect{ subject }.to change{ user.reload.reset_password_token }.from(nil).to(token)
                      .and change{ user.reload.reset_password_sent_at }.from(nil).to(be_within(2).of(sent_at))
    end
  end

  describe "#reset_password_period_valid?" do
    subject { user.reset_password_period_valid? }

    let(:user) do
      FactoryBot.create(:user_password_auth, reset_password_sent_at: reset_password_sent_at)
    end

    context "when reset_password_sent_at exists" do
      context "and expired" do
        let(:reset_password_sent_at) { 3.hours.ago - 1.second }
        it { is_expected.to be false }
      end

      context "and not expired" do
        let(:reset_password_sent_at) { 3.hours.ago + 2.seconds }
        it { is_expected.to be true }
      end
    end

    context "when reset_password_sent_at does not exist" do
      let(:reset_password_sent_at) { nil }
      it { is_expected.to be false }
    end
  end

  describe "#clear_reset_password_attrs" do
    let(:user) do
      FactoryBot.create(:user_password_auth,
        reset_password_token: SecureRandom.urlsafe_base64,
        reset_password_sent_at: Time.current
      )
    end
    it "clears attributes" do
      user.clear_reset_password_attrs
      expect(user).to have_attributes(reset_password_token: nil, reset_password_sent_at: nil)
    end
  end
end
