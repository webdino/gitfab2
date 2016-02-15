require "spec_helper"

describe MembershipsController, type: :controller do
  disconnect_sunspot
  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}

  describe "GET index" do
    before do
      sign_in user
      group = Group.create name: "foo"
      get :index, user_id: user.id
    end
    subject{response}
    it{should render_template :index}
  end

  describe "POST create" do
    context "with valid params" do
      before do
        sign_in user
        group = Group.create name: "foo"
        xhr :post, :create, user_id: user.id,
          membership: {group_id: group.id.to_s}, format: :json
      end
      it_behaves_like "success"
      it_behaves_like "render template", "create"
    end
    context "with invalid params" do
      before do
        sign_in user
        xhr :post, :create, user_id: user.id,
          membership: {group_id: "unexisted_group"}, format: :json
      end
      it{expect render_template 'error/failed', status: 400}
    end
  end

  describe "PATCH update" do
    context "with invalid params" do
      let(:membership_params){{role: "editor"}}
      before do
        sign_in user
        group = Group.create name: "foo"
        membership = user.memberships.create group_id: group.id
        patch :update, user_id: user.id, id: membership.id,
          membership: membership_params, format: :json
      end
      it{should render_template :update}
    end
    context "with invalid params" do
      let(:membership_params){{role: "unknown_role"}}
      before do
        sign_in user
        group = Group.create name: "foo"
        membership = user.memberships.create group_id: group.id
        xhr :post, :create, user_id: user.id, id: membership.id,
          membership: membership_params, format: :json
      end
      it{expect render_template 'error/failed', status: 400}
    end
  end

  describe "DELETE destroy" do
    context "when a user destroyed own membership" do
      before do
        sign_in user
        group = Group.create name: "foo"
        membership = user.memberships.create group_id: group.id
        delete :destroy, user_id: user.id,
          id: membership.id, format: :json
      end
      it{should render_template :destroy}
    end
  end
end
