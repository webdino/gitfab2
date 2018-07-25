# frozen_string_literal: true

describe UsersController, type: :controller do
  let(:user) { FactoryBot.create :user }

  describe 'GET index' do
    subject { get :index, format: :json }
    it { is_expected.to be_successful }
  end

  describe 'GET edit' do
    subject { get :edit, params: { id: user } }
    it { is_expected.to render_template :edit }
  end

  describe 'PATCH update' do
    subject { patch :update, params: { id: user, user: { name: 'foo' } } }
    it { is_expected.to redirect_to edit_user_path(user.reload) }
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: user } }
    it { is_expected.to redirect_to root_path }
  end
end
