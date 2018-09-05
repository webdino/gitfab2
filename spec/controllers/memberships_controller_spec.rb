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

  describe 'PATCH update' do
    subject { patch :update, params: { user_id: user.id, id: membership.id, membership: params } }
    let(:membership) { FactoryBot.create(:membership) }
    let(:user) { membership.user }
    before { sign_in user }

    context 'with valid params' do
      let(:params) { { role: 'admin' } }
      it do
        subject
        expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true })
      end
    end

    context 'with valid params' do
      let(:params) { { role: 'invalid' } }
      it do
        subject
        expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { user_id: user.id, id: membership.id } }

    let!(:group) { FactoryBot.create(:group)}
    let!(:membership) { user.memberships.create(group: group) }

    before { sign_in user }

    context 'when 2 group members (admins)' do
      # Another user's membership
      before { FactoryBot.create(:membership, group: group, role: 'admin') }

      it 'deletes 1 membership' do
        expect { subject }.to change { Membership.count }.by(-1)
      end
    end

    context 'when 2 group members (admin and editor)' do
      before { FactoryBot.create(:membership, group: group, role: 'editor') }

      it 'does NOT delete admin membership' do
        expect { subject }.not_to change { Membership.count }
      end
    end

    context 'when 1 group member' do
      it 'does NOT delete membership' do
        expect { subject }.not_to change { Membership.count }
      end
    end
  end
end
