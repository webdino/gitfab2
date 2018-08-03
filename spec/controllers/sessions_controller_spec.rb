RSpec.describe SessionsController, type: :controller do
  describe "GET #index" do
    subject { get :index }

    context "when user already signed in" do
      before { sign_in(FactoryBot.create(:user)) }
      it { is_expected.to redirect_to root_path }
    end

    context "when user does not signed in" do
      it { is_expected.to be_successful }
    end
  end

  describe "POST #create" do
    subject { post :create, params: params }
    let(:params) { {} }

    context "when user already signed in" do
      before { sign_in(FactoryBot.create(:user)) }
      it { is_expected.to redirect_to root_path }
    end

    context "when user does not signed in" do
      let(:params) { { provider: "github" } }

      context "on oauth sign in" do
        before do
          request.env["omniauth.auth"] = OpenStruct.new(
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

      context "on password sign in" do
        let(:user) do
          attributes = FactoryBot.attributes_for(:user)
          User::PasswordAuth.create(attributes.merge(password: 'password', password_confirmation: 'password'))
        end

        context "with valid params" do
          let(:params) { { sign_in: { name: user.name, password: 'password' } } }
          it { is_expected.to redirect_to root_path }
        end

        context "with invalid params" do
          let(:params) { { sign_in: { name: user.name, password: 'wrong_password' } } }
          it { is_expected.to be_successful }
        end
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
