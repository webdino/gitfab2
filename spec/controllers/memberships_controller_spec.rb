# frozen_string_literal: true

describe MembershipsController, type: :controller do
  let(:user) { FactoryBot.create :user }
  let(:other) { FactoryBot.create :user }
  subject { response }

  describe 'GET index' do
    before do
      sign_in user
      Group.create name: 'foo'
      get :index, user_id: user.id
    end
    it { is_expected.to render_template :index }
  end

  describe 'POST create' do
    context 'with valid params' do
      before do
        sign_in user
        group = Group.create name: 'foo'
        xhr :post, :create, user_id: user.id,
                            membership: { group_id: group.id.to_s }, format: :json
      end
      it_behaves_like 'success'
      it_behaves_like 'render template', 'create'
    end
    context 'with invalid params' do
      before do
        sign_in user
        xhr :post, :create, user_id: user.id,
                            membership: { group_id: 'unexisted_group' }, format: :json
      end
      it_behaves_like 'render template', 'failed'
    end
  end

  describe 'PATCH update' do
    context 'with invalid params' do
      let(:membership_params) { { role: 'editor' } }
      before do
        sign_in user
        group = Group.create name: 'foo'
        membership = user.memberships.create group_id: group.id
        patch :update, user_id: user.id, id: membership.id,
                       membership: membership_params, format: :json
      end
      it { is_expected.to render_template :update }
    end
    context 'with invalid params' do
      let(:membership_params) { { role: 'unknown_role' } }
      before do
        sign_in user
        group = Group.create name: 'foo'
        membership = user.memberships.create group_id: group.id
        xhr :post, :create, user_id: user.id, id: membership.id,
                            membership: membership_params, format: :json
      end
      it_behaves_like 'render template', 'failed'
    end
  end

  describe 'DELETE destroy' do
    context 'when a user destroyed own membership' do
      before do
        sign_in user
        group = Group.create name: 'foo'
        membership = user.memberships.create group_id: group.id
        delete :destroy, user_id: user.id,
                         id: membership.id, format: :json
      end
      it { is_expected.to render_template :destroy }
    end
  end
end
