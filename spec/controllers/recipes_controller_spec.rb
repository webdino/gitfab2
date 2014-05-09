require "spec_helper"

describe RecipesController do
  disconnect_sunspot
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group){FactoryGirl.create :group, creator: user1}
  let(:g_editor) do
    FactoryGirl.create(:user).tap do |u|
      group.members << u
    end
  end
  let(:group2){FactoryGirl.create :group, creator: user2}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:valid_attributes){{name: "recipe_#{SecureRandom.hex 16}", title: "title"}}

  render_views

  describe "GET new" do
    context "a user recipe" do
      context "owned by oneself" do
        before do
          sign_in recipe.owner
          get :new, user_id: recipe.owner_id
        end
        it_behaves_like "success"
      end
      context "owned by others" do
        before do
          sign_in g_recipe.owner.creator
          get :new, group_id: g_recipe.owner_id
        end
        it_behaves_like "success"
      end
    end
    context "a group recipe" do
      context "when the user is an admin of the group" do
        before do
          sign_in user2
          get :new, user_id: recipe.owner_id
        end
        it_behaves_like "unauthorized"
      end
      context "when the user is an editor of the group" do
        before do
          sign_in g_editor
          get :new, group_id: g_recipe.owner_id
        end
        it_behaves_like "unauthorized"
      end
      context "when the user is not an admin of the group" do
        before do
          sign_in user2
          get :new, group_id: g_recipe.owner_id
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "POST create" do
    context "a user recipe" do
      context "with the owner" do
        before do
          sign_in user1
          post :create, user_id: user1.name, 
            recipe: valid_attributes
        end
        subject{response}
        it{should redirect_to edit_recipe_path(user1.recipes.last, owner_name: user1.name)}
      end
      context "with a non-owner" do
        before do
          sign_in user2
          post :create, user_id: user1.name, 
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
    context "a group recipe" do
      context "with an admin user" do
        before do
          sign_in user1
          post :create, group_id: group.name, 
            recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
      context "when the user is an editor of the group" do
        before do
          sign_in g_editor
          post :create, group_id: group.name, 
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
      context "with a non-admin user" do
        before do
          sign_in user2
          post :create, group_id: group.name, 
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "POST fork via create" do
    context "a user recipe" do
      context "as a user recipe" do
        before do
          sign_in user1
          post :create, user_id: user1.name, 
            base_recipe_id: recipe.id
        end
        it_behaves_like "redirected"
      end
      context "as a group recipe" do
        before do
          sign_in user1
          post :create, group_id: group.name, 
            base_recipe_id: recipe.id
        end
        it_behaves_like "redirected"
      end
    end
    context "a group recipe" do
      context "as a user recipe" do
        before do
          sign_in user1
          post :create, user_id: user1.name, 
            base_recipe_id: g_recipe.id
        end
        it_behaves_like "redirected"
      end
      context "as a group recipe" do
        before do
          sign_in user2
          post :create, group_id: group2.name, 
            base_recipe_id: g_recipe.id
        end
        it_behaves_like "redirected"
      end
    end
  end

  describe "PATCH update" do
    context "a user recipe" do
      context "owned by oneself" do
        before do
          sign_in recipe.owner
          patch :update, user_id: recipe.owner_id,
            id: recipe.id, recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
      context "owned by others" do
        before do
          sign_in user2
          patch :update, user_id: recipe.owner_id, id: recipe.id,
            recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
    context "a group recipe" do
      context "when the user is an admin of the group" do
        before do
          sign_in g_recipe.owner.creator
          patch :update, group_id: g_recipe.owner_id,
            id: g_recipe.id, recipe: valid_attributes
        end
        it_behaves_like "redirected"
      end
      context "when the user is not an admin of the group" do
        before do
          sign_in user2
          patch :update, group_id: g_recipe.owner_id,
            id: g_recipe.id, recipe: valid_attributes
        end
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "DELETE destroy" do
    context "a user recipe" do
      context "owned by oneself" do
        before do
          sign_in recipe.owner
          delete :destroy, user_id: recipe.owner_id,
            id: recipe.id
        end
        it_behaves_like "redirected"
      end
      context "owned by others" do
        before do
          sign_in g_recipe.owner.creator
          delete :destroy, group_id: g_recipe.owner_id,
            id: g_recipe.id
        end
        it_behaves_like "redirected"
      end
    end
    context "a group recipe" do
      context "when the user is an admin of the group" do
        before do
          sign_in g_recipe.owner.creator
          delete :destroy, group_id: g_recipe.owner_id,
            id: g_recipe.id
        end
        it_behaves_like "redirected"
      end
      context "when the user is not an admin of the group" do
        before do
          sign_in user2
          delete :destroy, group_id: g_recipe.owner_id,
            id: g_recipe.id
        end
        it_behaves_like "unauthorized"
      end
    end
  end
end
