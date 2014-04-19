require "spec_helper"

describe RecipesController do
  disconnect_sunspot
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group){FactoryGirl.create :group, creator: user1}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:valid_attributes){{name: "recipe_#{SecureRandom.hex 16}", title: "title"}}

  render_views

  describe "GET new" do

    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return recipe.owner
          get :new, user_id: recipe.owner_id
        end
        it_behaves_like "success"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return g_recipe.owner.creator
          get :new, group_id: g_recipe.owner_id
        end
        it_behaves_like "success"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          get :new, user_id: recipe.owner_id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          get :new, group_id: g_recipe.owner_id
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "GET edit" do
    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return recipe.owner
          get :edit, user_id: recipe.owner_id, id: recipe.id
        end
        it_behaves_like "success"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return g_recipe.owner.creator
          get :edit, group_id: g_recipe.owner_id, id: g_recipe.id
        end
        it_behaves_like "success"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          get :edit, user_id: recipe.owner_id, id: recipe.id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          get :edit, group_id: g_recipe.owner_id, id: g_recipe.id
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
            post :create, user_id: user1.name, 
              recipe: valid_attributes
          end
          it_behaves_like "redirected"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, group_id: group.name, 
              recipe: valid_attributes
          end
          it_behaves_like "redirected"
        end
      end
      context "with non owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, user_id: user1.name, 
              recipe: valid_attributes
          end
          it_behaves_like "unauthorized"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, group_id: group.name, 
              recipe: valid_attributes
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
            post :create, user_id: user1.name, 
              base_recipe_id: recipe.id
          end
          it_behaves_like "redirected"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user1
            post :create, group_id: group.id, base_recipe_id: recipe.id
          end
          it_behaves_like "redirected"
        end
      end
      context "with non owner" do
        context "(user)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, user_id: user1.name, 
              base_recipe_id: recipe.id
          end
          it_behaves_like "unauthorized"
        end
        context "(group)" do
          before do
            controller.stub(:current_user).and_return user2
            post :create, group_id: group.name, 
              base_recipe_id: recipe.id
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
          controller.stub(:current_user).and_return recipe.owner
          patch :update, user_id: recipe.owner_id,
            id: recipe.id, recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return g_recipe.owner.creator
          patch :update, group_id: g_recipe.owner_id,
            id: g_recipe.id, recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          patch :update, user_id: recipe.owner_id, id: recipe.id,
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          patch :update, group_id: g_recipe.owner_id,
            id: g_recipe.id, recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return recipe.owner
          delete :destroy, user_id: recipe.owner_id,
            id: recipe.id
        end
        it_behaves_like "redirected"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return g_recipe.owner.creator
          delete :destroy, group_id: g_recipe.owner_id,
            id: g_recipe.id
        end
        it_behaves_like "redirected"
      end
    end
    context "with non owner" do
      context "(user)" do
        before do
          controller.stub(:current_user).and_return user2
          delete :destroy, user_id: recipe.owner_id,
            id: recipe.id
        end
        it_behaves_like "unauthorized"
      end
      context "(group)" do
        before do
          controller.stub(:current_user).and_return user2
          delete :destroy, group_id: g_recipe.owner_id,
            id: g_recipe.id
        end
        it_behaves_like "unauthorized"
      end
    end
  end
end
