require "spec_helper"

describe RecipesController do
  disconnect_sunspot
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group1){FactoryGirl.create :group, creator: user1}
  let(:recipe1){FactoryGirl.create :recipe, user_id: user1.id}
  let(:g_recipe1){FactoryGirl.create :recipe, group_id: group1.id}
  let(:valid_attributes){{name: "recipe_#{SecureRandom.uuid}", title: "title"}}

  render_views

  describe "GET new" do

    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user1
          get :new, user_id: user1.id
        end
        it_behaves_like "success"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user1
          get :new, group_id: group1.id
        end
        it_behaves_like "success"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          get :new, user_id: user1.id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          get :new, group_id: group1.id
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "GET edit" do
    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user1
          get :edit, user_id: user1.id, id: recipe1.id
        end
        it_behaves_like "success"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user1
          get :edit, group_id: group1.id, id: g_recipe1.id
        end
        it_behaves_like "success"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          get :edit, user_id: user1.id, id: recipe1.id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          get :edit, group_id: group1.id, id: g_recipe1.id
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "POST create" do
    context "when newly create" do
      context "with owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, user_id: user1.id, recipe: valid_attributes
          end
          it_behaves_like "redirected"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, group_id: group1.id, recipe: valid_attributes
          end
          it_behaves_like "redirected"
        end
      end
      context "with non owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, user_id: user1.id, recipe: valid_attributes
          end
          it_behaves_like "unauthorized"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, group_id: group1.id, recipe: valid_attributes
          end
          it_behaves_like "unauthorized"
        end
      end
    end
    context "when create by forking" do
      context "with owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, user_id: user1.id, base_recipe_id: recipe1.id
          end
          it_behaves_like "redirected"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, group_id: group1.id, base_recipe_id: recipe1.id
          end
          it_behaves_like "redirected"
        end
      end
      context "with non owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, user_id: user1.id, base_recipe_id: recipe1.id
          end
          it_behaves_like "unauthorized"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, group_id: group1.id, base_recipe_id: recipe1.id
          end
          it_behaves_like "unauthorized"
        end
      end
    end
  end

  describe "PATCH update" do
    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user1
          patch :update, user_id: user1.id, id: recipe1.id,
            recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user1
          patch :update, group_id: group1.id, id: g_recipe1.id,
            recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          patch :update, user_id: user1.id, id: recipe1.id,
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          patch :update, group_id: group1.id, id: g_recipe1.id,
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user1
          delete :destroy, user_id: user1.id, id: recipe1.id
        end
        it_behaves_like "redirected"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user1
          delete :destroy, group_id: group1.id, id: g_recipe1.id
        end
        it_behaves_like "redirected"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          delete :destroy, user_id: user1.id, id: recipe1.id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          delete :destroy, group_id: group1.id, id: g_recipe1.id
        end
        it_behaves_like "unauthorized"
      end
    end
  end
end
