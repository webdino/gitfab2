require "spec_helper"

describe MembershipsController do
  disconnect_sunspot
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group1){FactoryGirl.create :group, creator: user1}
  let(:membership1){group1.memberships.first}
  let(:valid_attributes){{user_id: user2.id, group_id: group1.id, role: Membership::ROLE[:admin]}}

  describe "valid attributes" do
    subject do
      ms = Membership.new(valid_attributes)
      ms.valid?
    end
    it{should be true}
  end

  describe "POST create" do
    before do
      controller.stub(:current_user).and_return user1
      post :create, group_id: group1.id,
        membership: membership_params, format: :json
    end
    context "with valid params" do
      let(:membership_params){valid_attributes}
      it_behaves_like "success"
      it_behaves_like "render template", "create"
    end
    context "with invalid params" do
      let(:membership_params){{role: nil}}
      it_behaves_like "success"
      it_behaves_like "render template", "failed"
    end
  end

  describe "PATCH update" do
    before do
      controller.stub(:current_user).and_return user1
      patch :update, group_id: group1.id, id: membership1.id,
        membership: membership_params, format: :json
    end
    context "with valid params" do
      let(:membership_params){valid_attributes}
      it_behaves_like "success"
      it_behaves_like "render template", "update"
    end
    context "with invalid params" do
      let(:membership_params){{role: nil}}
      it_behaves_like "success"
      it_behaves_like "render template", "failed"
    end
  end

  describe "DELETE destroy" do
    before do
      controller.stub(:current_user).and_return user1
      delete :destroy, group_id: group1.id, user_id: user1.id,
        id: membership1.id, format: :json
    end
    it_behaves_like "render template", "destroy"
  end
end
