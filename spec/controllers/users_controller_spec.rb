# frozen_string_literal: true

describe UsersController, type: :controller do
  describe 'GET index' do
    subject { get :index, format: :json }
    it { is_expected.to be_successful }
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
