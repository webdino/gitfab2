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

        context "when user already signed in" do
          before { sign_in(user) }
          let(:user) { FactoryBot.create(:user) }
          let(:identity) { FactoryBot.create(:identity, user: identity_user) }
          let(:identity_user) { nil }

          it { is_expected.to redirect_to edit_user_path }

          context "and identity has another user" do
            let(:identity_user) { FactoryBot.create(:user) }
            it do
              expect{ subject }.not_to change{ identity.reload.user }
              expect(flash[:danger]).to eq "This account is connected with another user"
            end
          end

          context "and identity has current_user" do
            let(:identity_user) { user }
            it do
              expect{ subject }.not_to change{ identity.reload.user }
              expect(flash[:success]).to eq "Successfully signed in to #{identity.provider}!"
            end
          end

          context "and identity does not have user" do
            let(:identity_user) { nil }
            it do
              expect{ subject }.to change{ identity.reload.user }.from(nil).to(user)
              expect(flash[:success]).to eq "Successfully signed in to #{identity.provider}!"
            end
          end
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

          context "when user have password" do
            it { is_expected.to redirect_to root_path }
          end

          context "when user do not have password" do
            let(:user) { FactoryBot.create(:user, password_digest: nil) }
            it { is_expected.to be_successful }
          end
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
