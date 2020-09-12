# frozen_string_literal: true

describe MembershipsController, type: :controller do

  describe 'GET index' do
    let(:user) { FactoryBot.create :user }
    subject { response }
    before do
      sign_in user
      Group.create name: 'foo'
      get :index, params: { user_id: user.id }
    end
    it { is_expected.to render_template :index }
  end

  describe 'PATCH update' do
    subject { patch :update, params: { user_id: user.to_param, id: membership.id, membership: membership_params } }
    let(:group) { FactoryBot.create :group }
    let(:user) { FactoryBot.create :user }
    let(:membership) { FactoryBot.create(:membership, group: group, user: user, role: "editor") }

    context 'when an administrator is signed in' do
      before do
        current_user = FactoryBot.create(:user)
        sign_in(current_user)

        FactoryBot.create(:membership, group: group, user: current_user, role: "admin")
      end

      context 'with valid params' do
        let(:membership_params) { { role: 'admin' } }

        it do
          subject
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true })
        end

        it { expect { subject }.to change { membership.reload.role }.from("editor").to("admin") }
      end
  
      context 'with valid params' do
        let(:membership_params) { { role: 'invalid' } }
        it do
          subject
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end

    context 'when an editor is signed in' do
      before do
        current_user = FactoryBot.create(:user)
        sign_in(current_user)

        FactoryBot.create(:membership, group: group, user: current_user, role: "editor")
      end

      let(:membership_params) { { role: 'admin' } }

      it { expect { subject }.to_not change { membership.reload.role } }
    end

    context 'when an anonymous' do
      let(:membership_params) { { role: 'admin' } }

      it { expect { subject }.to_not change { membership.reload.role } }
    end
  end

  describe 'DELETE destroy' do
    context 'when an administrator is signed in' do
      let!(:current_membership) { FactoryBot.create(:membership, group: group, user: current_user, role: "admin") }
      let(:current_user) { FactoryBot.create(:user) }
      let(:group) { FactoryBot.create(:group) }

      before do
        sign_in(current_user)
      end

      context 'when 2 group members (admins)' do
        # Another user's membership
        before { FactoryBot.create(:membership, group: group, role: 'admin') }
  
        subject { delete :destroy, params: { user_id: current_user.to_param, id: current_membership.id } }

        it 'deletes 1 membership' do
          expect { subject }.to change { Membership.count }.by(-1)
        end
      end
  
      context 'when 2 group members (admin and editor)' do
        before { FactoryBot.create(:membership, group: group, role: 'editor') }

        subject { delete :destroy, params: { user_id: current_user.to_param, id: current_membership.id } }
  
        it 'does NOT delete admin membership' do
          expect { subject }.not_to change { Membership.count }
        end
      end
  
      context 'when 1 group member' do
        subject { delete :destroy, params: { user_id: current_user.to_param, id: current_membership.id } }
  
        it 'does NOT delete membership' do
          expect { subject }.not_to change { Membership.count }
        end
      end
    end

    context 'when an editor is signed in' do
      let!(:current_membership) { FactoryBot.create(:membership, group: group, user: current_user, role: "editor") }
      let(:current_user) { FactoryBot.create(:user) }
      let(:group) { FactoryBot.create(:group) }

      before do
        sign_in(current_user)
      end

      context 'when 2 group members (admins)' do
        # Another user's membership
        before { FactoryBot.create(:membership, group: group, role: 'admin') }
  
        subject { delete :destroy, params: { user_id: current_user.to_param, id: current_membership.id } }

        it 'does NOT delete the membership' do
          expect { subject }.to_not change(Membership, :count)
        end
      end
    end

    context 'when an anonymous' do
      let!(:membership) { FactoryBot.create(:membership, group: group, user: user, role: "editor") }
      let(:user) { FactoryBot.create(:user) }
      let(:group) { FactoryBot.create(:group) }

      context 'when 2 group members (admins)' do
        # Another user's membership
        before { FactoryBot.create(:membership, group: group, role: 'admin') }
  
        subject { delete :destroy, params: { user_id: user.to_param, id: membership.id } }

        it 'does NOT delete the membership' do
          expect { subject }.to_not change(Membership, :count)
        end
      end
    end
  end
end
