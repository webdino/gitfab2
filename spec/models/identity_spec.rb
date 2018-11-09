# frozen_string_literal: true

RSpec.describe Identity, type: :model do
  describe ".find_or_create_with_omniauth" do
    subject { Identity.find_or_create_with_omniauth(auth_hash) }
    let(:auth_hash) do
      OpenStruct.new(
        provider: identity&.provider || "github",
        uid: identity&.uid || "default_uid",
        info: OpenStruct.new(
          name: identity&.name || "default name",
          nickname: identity&.nickname || "nickname",
          email: identity&.email || "default@sample.com",
          image: identity&.image || "https://picsum.photos/1"
        )
      )
    end

    context "when identity exists" do
      let!(:identity) { FactoryBot.create(:identity) }
      it { is_expected.to be_kind_of Identity }
      it { expect{ subject }.not_to change{ Identity.count } }
    end

    context "when identity exists" do
      let!(:identity) { nil }
      it { is_expected.to be_kind_of Identity }
      it { expect{ subject }.to change{ Identity.count }.by(1) }
    end
  end

  describe ".crypt" do
    subject { Identity.crypt }
    it { is_expected.to be_kind_of ActiveSupport::MessageEncryptor }
  end

  describe ".find_by_encrypted_id" do
    subject { Identity.find_by_encrypted_id(encrypted_id) }
    let(:identity) { FactoryBot.create(:identity) }
    let(:encrypted_id) { identity.encrypted_id }
    it { is_expected.to eq identity }
  end

  describe "#encrypted_id" do
    it do
      identity = FactoryBot.create(:identity)
      encrypted_id = identity.encrypted_id
      decrypted_id = Identity.crypt.decrypt_and_verify(Base64.urlsafe_decode64(encrypted_id))
      expect(decrypted_id).to eq identity.id
    end
  end
end
