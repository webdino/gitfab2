# frozen_string_literal: true

require 'spec_helper'

describe MembersController, type: :controller do
  let(:group) { FactoryGirl.create :group }
  let(:user) { FactoryGirl.create :user }

  subject { response }

  describe 'POST create' do
    before do
      xhr :post, :create, group_id: group.id, member_name: user.name
      user.reload
    end
    it { is_expected.to render_template :create }
    it { expect(user).to have(1).memberships }
  end
end
