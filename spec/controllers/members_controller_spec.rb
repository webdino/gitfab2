# frozen_string_literal: true

require 'spec_helper'

describe MembersController, type: :controller do
  let(:group) { FactoryBot.create :group }
  let(:user) { FactoryBot.create :user }

  subject { response }

  describe 'POST create' do
    before do
      xhr :post, :create, group_id: group.id, member_name: user.name
      user.reload
    end
    it { is_expected.to render_template :create }
    it 'has 1 membership' do
      expect(user.memberships.size).to eq 1
    end
  end
end
