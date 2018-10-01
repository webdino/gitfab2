# frozen_string_literal: true

RSpec.describe PasswordsController, type: :controller do
  describe "GET #new" do
    it { expect(get :new).to have_http_status(:success) }
  end

  describe "POST #create" do
    subject { post :create, params: { email: email } }
    let(:email) { nil }

    it { is_expected.to redirect_to new_password_path }

    context "with exists email" do
      let(:email) { "exists-email@example.com" }
      before { FactoryBot.create(:user_password_auth, email: email, email_confirmation: email) }
      it do
        expect_any_instance_of(User::PasswordAuth).to receive(:send_reset_password_instructions)
        subject
      end
    end

    context "without exists email" do
      let(:email) { "not-exists-email@example.com" }
      it do
        expect_any_instance_of(User::PasswordAuth).not_to receive(:send_reset_password_instructions)
        subject
      end
    end
  end

  describe "GET #edit" do
    subject { get :edit, params: { reset_password_token: reset_password_token } }

    context "with reset_password_token" do
      let(:reset_password_token) { SecureRandom.urlsafe_base64 }
      it { is_expected.to have_http_status(:success) }
    end

    context "without reset_password_token" do
      let(:reset_password_token) { nil }
      it { is_expected.to redirect_to sessions_path }
    end
  end

  describe "PATCH #update" do
    subject { patch :update, params: { user: user_params } }
    let(:user_params) do
      {
        reset_password_token: reset_password_token,
        password: password,
        password_confirmation: password_confirmation
      }
    end
    let(:password) { "123456" }
    let(:password_confirmation) { password }

    context "without exists reset_password_token" do
      let(:reset_password_token) { "invalid" }
      it { is_expected.to redirect_to new_password_path }
    end

    context "with exists reset_password_token" do
      let(:reset_password_token) { SecureRandom.urlsafe_base64 }
      before do
        FactoryBot.create(:user_password_auth,
          reset_password_token: reset_password_token,
          reset_password_sent_at: Time.current
        )
      end

      context "with expired token" do
        it do
          expect_any_instance_of(User::PasswordAuth).to receive(:reset_password_period_valid?).and_return(false)
          is_expected.to redirect_to new_password_path
        end
      end

      context "with valid token" do
        before do
          expect_any_instance_of(User::PasswordAuth).to receive(:reset_password_period_valid?).and_return(true)
        end

        context "with valid user params" do
          it do
            expect_any_instance_of(User::PasswordAuth).to receive(:clear_reset_password_attrs)
            is_expected.to redirect_to sessions_path
          end
        end

        context "with invalid user params" do
          let(:password_confirmation) { "invalid" }
          it do
            expect_any_instance_of(User::PasswordAuth).not_to receive(:clear_reset_password_attrs)
            is_expected.to have_http_status(:success)
          end
        end
      end
    end
  end
end
