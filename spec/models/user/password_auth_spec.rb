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
end
