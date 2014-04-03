require "spec_helper"

describe GroupsController do
  disconnect_sunspot
  let(:user1){FactoryGirl.create :user}
  let(:group1){FactoryGirl.create :group}
  let(:valid_attributes){{name: "group_#{SecureRandom.uuid}"}}

  describe "GET index" do
    before do
      controller.stub(:current_user).and_return user1
      get :index
    end
    it_behaves_like "success"
  end

  describe "GET show" do
    before do
      controller.stub(:current_user).and_return user1
      get :show, id: group1.id
    end
    it_behaves_like "success"
    it_behaves_like "render template", "show"
  end

  describe "GET new" do
    before do
      controller.stub(:current_user).and_return user1
      get :new
    end
    it_behaves_like "success"
    it_behaves_like "render template", "new"
  end

  describe "POST create" do
    before do
      controller.stub(:current_user).and_return user1
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
    before do
      controller.stub(:current_user).and_return user1
      get :edit, id: group1.id
    end
    it_behaves_like "success"
    it_behaves_like "render template", "edit"
  end

  describe "PATCH update" do
    before do
      @orig_group = group1.dup
      controller.stub(:current_user).and_return user1
      patch :update, id: group1.id, group: group_params
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

  describe "DELETE destroy" do
    before do
      controller.stub(:current_user).and_return user1
      delete :destroy, id: group1.id
    end
    it_behaves_like "redirected"
  end
end
