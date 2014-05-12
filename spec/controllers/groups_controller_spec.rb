require "spec_helper"

describe GroupsController do
  disconnect_sunspot
  render_views

  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}
  let(:group){FactoryGirl.create :group}
  let(:valid_attributes){{name: "group_#{SecureRandom.hex 10}"}}

  before do

  end

  describe "GET index" do
    before do
      sign_in user
      get :index
    end
    it_behaves_like "success"
  end

  describe "GET show" do
    before do
      sign_in user
      group.add_admin user
      get :show, id: group.id
    end
    it_behaves_like "success"
    it_behaves_like "render template", "show"
  end

  describe "GET new" do
    before do
      sign_in user
      get :new
    end
    it_behaves_like "success"
    it_behaves_like "render template", "new"
  end

  describe "POST create" do
    before do
      sign_in user
      post :create, group: group_params
    end
    context "with valid params" do
      let(:group_params){valid_attributes}
      it_behaves_like "redirected"
    end
    context "with invalid params" do
      let(:group_params){{name: nil}}
      it_behaves_like "success"
      it_behaves_like "render template", "new"
    end
  end

  describe "GET edit" do
    describe "as an admin" do
      before do
        sign_in user
        group.add_admin user
        get :edit, id: group.id
      end
      it_behaves_like "success"
      it_behaves_like "render template", "edit"
    end
    describe "as an editor" do
      before do
        sign_in other
        group.add_admin user
        group.members << other
        get :edit, id: group.id
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "PATCH update" do
    describe "as an admin" do
      before do
        sign_in user
        group.add_admin user
        patch :update, id: group.id, group: group_params
      end
      context "with valid params" do
        let(:group_params){valid_attributes}
        it_behaves_like "redirected"
      end
      context "with invalid params" do
        let(:group_params){{name: nil}}
        it_behaves_like "success"
        it_behaves_like "render template", "edit"
      end
    end
    describe "as an editor" do
      before do
        group.add_admin user
        @orig_group = group.dup
        sign_in other
        group.members << other
        patch :update, id: group.id, group: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "DELETE destroy" do
    describe "as an admin" do
      before do
        sign_in user
        group.add_admin user
        delete :destroy, id: group.id
      end
      it_behaves_like "redirected"
    end
    describe "as an editor" do
      before do
        sign_in other
        group.add_admin user
        group.members << other
        delete :destroy, id: group.id
      end
      it_behaves_like "unauthorized"
    end
  end
end
