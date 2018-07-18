# frozen_string_literal: true

describe MembersController, type: :controller do
  let(:group) { FactoryBot.create :group }
  let(:user) { FactoryBot.create :user }

  subject { response }

  describe 'POST create' do
    before do
      post :create, params: { group_id: group.id, member_name: user.name }, xhr: true
      user.reload
    end
    it { is_expected.to render_template :create }
    it 'has 1 membership' do
      expect(user.memberships.size).to eq 1
    end
  end
end
