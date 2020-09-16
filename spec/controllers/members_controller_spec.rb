# frozen_string_literal: true

describe MembersController, type: :controller do
  describe 'POST create' do
    let(:group) { FactoryBot.create :group }
    let(:user) { FactoryBot.create :user }

    subject { post :create, params: { group_id: group.id, member_name: user.name }, xhr: true }

    context 'when current_user is the group administrator' do
      before do
        sign_in FactoryBot.create(:membership, group: group, role: 'admin').user
      end
      
      it { is_expected.to render_template :create }
      it 'creates a membership' do
        expect { subject }.to change(user.memberships, :count).to eq 1
      end
    end

    context 'when current_user is the group editor' do
      before do
        sign_in FactoryBot.create(:membership, group: group, role: 'editor').user
      end
      
      it { is_expected.to_not render_template :create }
      it 'does not create a membership' do
        expect { subject }.to_not change(user.memberships, :count)
      end
    end

    context 'when current_user is not the group member' do
      before do
        sign_in FactoryBot.create(:user)
      end
      
      it { is_expected.to_not render_template :create }
      it 'does not create a membership' do
        expect { subject }.to_not change(user.memberships, :count)
      end
    end

    context 'when current_user is an anonymous' do
      it { is_expected.to_not render_template :create }
      it 'does not create a membership' do
        expect { subject }.to_not change(user.memberships, :count)
      end
    end
  end
end
