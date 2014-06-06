require "spec_helper"

describe MembersController, type: :controller do
  let(:group){FactoryGirl.create :group}
  let(:user){FactoryGirl.create :user}

  subject{response}

  describe "POST create" do
    before do
      xhr :post, :create, group_id: group.id, member: {name: user.name}
      user.reload
    end
    it{should render_template :create}
    it{expect(user).to have(1).memberships}
  end
end
