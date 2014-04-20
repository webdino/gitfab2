require "spec_helper"

describe WaysController do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:status){FactoryGirl.create :status, recipe: recipe}
  let(:g_status){FactoryGirl.create :status, recipe: g_recipe}
  let(:way){FactoryGirl.create :way, status: status}
  let(:g_way){FactoryGirl.create :way, status: g_status}
  let(:valid_attributes){{name: "name", description: "description"}}

  describe "POST create" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return recipe.owner
        xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, way: valid_attributes
      end
      it_behaves_like "operation without team privilege", :way

    end
    context "with a member of the group which owns the recipe" do
      before do
        controller.stub(:current_user).and_return user2
        g_recipe.owner.add_editor user2
        xhr :post, :create, group_id: g_recipe.owner.id, recipe_id: g_recipe.id,
          status_id: g_status.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "PATCH update" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return recipe.owner
        xhr :patch, :update, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, id: way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :patch, :update, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, id: way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with a member of the group which owns the recipe" do
      before do
        controller.stub(:current_user).and_return user2
        g_recipe.owner.add_editor user2
        xhr :patch, :update, group_id: g_recipe.owner.id, recipe_id: g_recipe.id,
          status_id: g_status.id, id: g_way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return recipe.owner
        xhr :delete, :destroy, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, id: way.id
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :delete, :destroy, user_id: recipe.owner.id, recipe_id: recipe.id,
          status_id: status.id, id: way.id
      end
      it_behaves_like "operation without team privilege", :way
    end
    context "with a member of the group which owns the recipe" do
      before do
        controller.stub(:current_user).and_return user2
        g_recipe.owner.add_editor user2
        xhr :delete, :destroy, group_id: g_recipe.owner.id, recipe_id: g_recipe.id,
          status_id: g_status.id, id: g_way.id
      end
      it_behaves_like "success"
    end
  end
end
