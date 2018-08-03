# frozen_string_literal: true

describe UsersController, type: :controller do
  describe 'GET index' do
    subject { get :index, format: :json }
    it { is_expected.to be_successful }
  end

  describe 'GET new' do
    subject { get :new, params: params }
    let(:params) { {} }

    it { is_expected.to be_successful }

    context 'on oauth sign up' do
      let(:params) { { token: identity.encrypted_id } }
      let(:identity) { FactoryBot.create(:identity, user: nil) }
      it do
        expect(Identity).to receive(:find_by_encrypted_id).and_call_original
        subject
      end
    end

    context 'on password sign up' do
      let(:params) { {} }
      it do
        expect(User::PasswordAuth).to receive(:new)
        subject
      end
    end
  end

  describe 'POST create' do
    subject { post :create, params: { user: user_params } }

    context 'on oauth sign up' do
      let(:identity) { FactoryBot.create(:identity, user: nil) }
      let(:encrypted_identity_id) { identity.encrypted_id }

      context 'with valid params' do
        let(:user_params) do
          {
            encrypted_identity_id: encrypted_identity_id,
            name: 'nickname', url: 'https://sample.com', location: 'Tokyo',
            avatar: fixture_file_upload('images/image.jpg'),
          }
        end

        it do
          expect{ subject }.to change{ User.count }.by(1)
                          .and change{ identity.reload.user }.from(nil).to(be_kind_of(User))
          is_expected.to redirect_to root_path
        end
      end

      context 'with invalid params' do
        let(:user_params) { { encrypted_identity_id: encrypted_identity_id, name: '' } }

        it do
          expect{ subject }.not_to change{ User.count }
          is_expected.to be_successful
        end
      end
    end


    context 'on password sign up' do
      context 'with valid params' do
        let(:user_params) do
          {
            password: 'password', password_confirmation: 'password',
            name: 'nickname', url: 'https://sample.com', location: 'Tokyo',
            avatar: fixture_file_upload('images/image.jpg'), encrypted_identity_id: nil
          }
        end

        it do
          expect{ subject }.to change{ User.count }.by(1)
          is_expected.to redirect_to root_path
        end
      end

      context 'with invalid params' do
        let(:user_params) do
          {
            password: 'password', password_confirmation: 'wrong password',
            name: 'nickname', encrypted_identity_id: nil
          }
        end

        it do
          expect{ subject }.not_to change{ User.count }
          is_expected.to be_successful
        end
      end
    end
  end

  describe 'GET edit' do
    subject { get :edit, params: { id: user } }
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to be_successful }
  end

  describe 'PATCH update' do
    subject { patch :update, params: { id: user, user: user_params } }
    let(:user) { FactoryBot.create(:user, name: 'before') }

    context 'with valid params' do
      let(:user_params) { { name: 'after' } }
      it do
        expect{ subject }.to change{ user.reload.name }.from('before').to('after')
        is_expected.to redirect_to edit_user_path(user)
      end
    end

    context 'with invalid params' do
      let(:user_params) { { name: '' } }
      it do
        expect{ subject }.not_to change{ user.reload.name }
        is_expected.to be_successful
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: user } }
    let!(:user) { FactoryBot.create(:user) }
    it do
      expect{ subject }.to change{ User.count }.by(-1)
      is_expected.to redirect_to root_path
    end
  end
end
