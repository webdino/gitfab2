# frozen_string_literal: true

shared_examples "Sign up Interface" do |obj|
  describe "#password_auth?" do
    it { expect(obj).to respond_to :password_auth? }
    it { expect(obj.password_auth?).to be_in [true, false] }
  end
end
