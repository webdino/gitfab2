RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    subject { get :create, provider: "github" }

    before { request.env["omniauth.auth"] = auth_hash }
    let(:auth_hash) do
      OpenStruct.new(
        provider: user&.provider || "github",
        uid: user&.uid || "default_uid",
        info: OpenStruct.new(
          name: user&.fullname || "default name",
          nickname: user&.name || "nickname",
          email: user&.email || "default@sample.com",
          image: user&.remote_avatar_url || "https://picsum.photos/1"
        )
      )
    end

    context "when user exists" do
      let(:user) { FactoryBot.create(:user) }
      it { is_expected.to redirect_to(root_path) }
      it { expect{ subject }.not_to change{ User.count } }
    end

    context "when user does not exist" do
      let(:user) { nil }
      it { is_expected.to redirect_to(root_path) }
      it { expect{ subject }.to change{ User.count }.to(1) }
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
