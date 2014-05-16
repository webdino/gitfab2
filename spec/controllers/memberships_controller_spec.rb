require "spec_helper"

describe MembershipsController do
  disconnect_sunspot
  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}
  let(:valid_attributes){{user_id: other.id, role: Membership::ROLE[:admin]}}

  describe "POST create" do
    before do
      sign_in user
      group = user.groups.create name: "foo"
      post :create, group_id: group.id,
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
      sign_in user
      group = user.groups.create name: "foo"
      membership = group.memberships.first
      patch :update, group_id: group.id, id: membership.id,
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
    context "when a user destroyed own membership" do
      before do
        sign_in user
        group = user.groups.create name: "foo"
        membership = group.memberships.last
        delete :destroy, group_id: group.id, user_id: user.id,
          id: membership.id, format: :json
      end
      it_behaves_like "render template", "destroy"
    end
    context "when a user destroyed other member's membership" do
      before do
        sign_in user
        group = user.groups.create name: "foo"
        group.members << FactoryGirl.create(:user)
        membership = group.memberships.last
        delete :destroy, group_id: group.id, user_id: user.id,
          id: membership.id, format: :json
      end
      it_behaves_like "render template", "destroy"
    end
  end
end
