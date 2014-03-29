require "spec_helper"

describe RecipesController do
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:recipe1){FactoryGirl.create :recipe, user_id: user1.id}
  let(:valid_attributes){{name: "recipe_#{SecureRandom.uuid}", title: "title"}}

  describe "GET new" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        get :new, user_id: user1.id
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        get :new, user_id: user1.id
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "GET edit" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        get :edit, user_id: user1.id, id: recipe1.id
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        get :edit, user_id: user1.id, id: recipe1.id
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "POST create" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        post :create, user_id: user1.id, recipe: valid_attributes
      end
      it_behaves_like "redirected"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        post :create, user_id: user1.id, recipe: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "PATCH update" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        patch :update, user_id: user1.id, id: recipe1.id,
          recipe: valid_attributes
      end
      it_behaves_like "redirected"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        patch :update, user_id: user1.id, id: recipe1.id,
          recipe: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "POST fork" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        post :fork, user_id: user1.id, recipe_id: recipe1.id
      end
      it_behaves_like "redirected"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        post :fork, user_id: user1.id, recipe_id: recipe1.id
      end
      it_behaves_like "redirected"
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        delete :destroy, user_id: user1.id, id: recipe1.id
      end
      it_behaves_like "redirected"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        delete :destroy, user_id: user1.id, id: recipe1.id
      end
      it_behaves_like "unauthorized"
    end
  end
end
