require "spec_helper"

describe ToolsController do
  disconnect_sunspot
  render_views

  let(:user){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:tool){FactoryGirl.create :tool, recipe_id: recipe.id}
  let(:g_tool){FactoryGirl.create :tool, recipe_id: g_recipe.id}
  let(:valid_attributes){{name: "name", url: "url", description: "description"}}

  describe "POST create" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return recipe.owner
        xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
          tool: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user
        xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
          tool: valid_attributes
      end
      it_behaves_like "operation without team privilege", :tool

    end
    context "with a member of the group which owns the recipe" do
      let(:group){FactoryGirl.create :group, creator: recipe.owner}
      before do
        controller.stub(:current_user).and_return user
        group.add_editor user
        recipe.update_attributes owner_id: group.id
        xhr :post, :create, group_id: group.id, recipe_id: recipe.id,
          tool: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "PATCH update" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user
        xhr :patch, :update, user_id: user.id, recipe_id: recipe.id,
          id: tool.id, tool: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :patch, :update, user_id: user.id, recipe_id: recipe.id,
          id: tool.id, tool: valid_attributes
      end
      it_behaves_like "operation without team privilege", :tool
    end
    context "with a member of the group which owns the recipe" do
      before do
        controller.stub(:current_user).and_return user2
        g_recipe.owner.add_editor user2
        xhr :patch, :update, user_id: user.id, recipe_id: g_recipe.id,
          id: g_tool.id, tool: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user
        xhr :delete, :destroy, user_id: user.id, recipe_id: recipe.id,
          id: tool.id
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :delete, :destroy, user_id: user.id, recipe_id: recipe.id,
          id: tool.id
      end
      it_behaves_like "operation without team privilege", :tool
    end
    context "with a member of the group which owns the recipe" do
      let(:group){FactoryGirl.create :group, creator: user}
      before do
        controller.stub(:current_user).and_return user2
        g_recipe.owner.add_editor user2
        xhr :delete, :destroy, user_id: user.id, recipe_id: g_recipe.id,
          id: g_tool.id
      end
      it_behaves_like "success"
    end
  end
end
