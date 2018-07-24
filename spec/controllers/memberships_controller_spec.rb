# frozen_string_literal: true

describe MembershipsController, type: :controller do
  let(:user) { FactoryBot.create :user }
  subject { response }

  describe 'GET index' do
    before do
      sign_in user
      Group.create name: 'foo'
      get :index, params: { user_id: user.id }
    end
    it { is_expected.to render_template :index }
  end

  describe 'DELETE destroy' do
    context 'when a user destroyed own membership' do
      before do
        sign_in user
        group = Group.create name: 'foo'
        membership = user.memberships.create group_id: group.id
        delete :destroy, params: { user_id: user.id, id: membership.id }, format: :json
      end
      it { is_expected.to render_template :destroy }
    end
  end
end
