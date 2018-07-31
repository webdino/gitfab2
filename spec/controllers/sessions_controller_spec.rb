RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    subject { get :create, params: { provider: "github" } }

    before { request.env["omniauth.auth"] = auth_hash }
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
      let(:identity) { FactoryBot.create(:identity) }
      it do
        expect{ subject }.not_to change{ Identity.count }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when identity does not exist" do
      let(:identity) { nil }
      it do
        expect{ subject }.to change{ Identity.count }.to(1)
        expect(response.location).to match new_user_path
      end
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy }
    before { session[:su] = user.id }
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to redirect_to(root_path) }
    it { expect{ subject }.to change{ session[:su] }.from(user.id).to(nil) }
  end
end
