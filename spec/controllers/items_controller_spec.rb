require "spec_helper"

["tool", "usage"].each do |klass|
  describe "#{klass.classify.pluralize}Controller".constantize do
    disconnect_sunspot
    render_views

    let(:user1){FactoryGirl.create :user}
    let(:user2){FactoryGirl.create :user}
    let(:recipe){FactoryGirl.create :user_recipe}
    let(:g_recipe){FactoryGirl.create :group_recipe}
    let("#{klass}1"){FactoryGirl.create "#{klass}", recipe_id: recipe.id}
    let("g_#{klass}1"){FactoryGirl.create "#{klass}", recipe_id: g_recipe.id}
    let(:valid_attributes){{name: "name", description: "description"}}

    describe "POST create" do
      context "with owner" do
        before do
          sign_in recipe.owner
          xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
            klass => valid_attributes
        end
        it_behaves_like "success"
      end
      context "with non owner" do
        before do
          sign_in user2
          xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
            klass => valid_attributes
        end
        it_behaves_like "operation without team privilege", klass

      end
      context "with a member of the group which owns the recipe" do
        let(:group){FactoryGirl.create :group, creator: recipe.owner}
        before do
          sign_in user2
          group.add_editor user2
          recipe.update_attributes owner_id: group.id, owner_type: Group.name
          xhr :post, :create, group_id: group.id, recipe_id: recipe.id,
            klass => valid_attributes
        end
        it_behaves_like "success"
      end
    end

    describe "PATCH update" do
      context "with owner" do
        before do
          sign_in recipe.owner
          xhr :patch, :update, user_id: recipe.owner.id, recipe_id: recipe.id,
            id: send("#{klass}1").id, klass => valid_attributes
        end
        it_behaves_like "success"
      end
      context "with non owner" do
        before do
          sign_in user2
          xhr :patch, :update, user_id: recipe.owner.id, recipe_id: recipe.id,
            id: send("#{klass}1").id, klass => valid_attributes
        end
        it_behaves_like "operation without team privilege", klass
      end
      context "with a member of the group which owns the recipe" do
        before do
          sign_in user2
          g_recipe.owner.add_editor user2
          xhr :patch, :update, group_id: g_recipe.owner.id, recipe_id: g_recipe.id,
            id: send("g_#{klass}1").id, klass => valid_attributes
        end
        it_behaves_like "success"
      end
    end

    describe "DELETE destroy" do
      context "with owner" do
        before do
          sign_in recipe.owner
          xhr :delete, :destroy, user_id: recipe.owner.id, recipe_id: recipe.id,
            id: send("#{klass}1").id
        end
        it_behaves_like "success"
      end
      context "with non owner" do
        before do
          sign_in user2
          xhr :delete, :destroy, user_id: recipe.owner.id, recipe_id: recipe.id,
            id: send("#{klass}1").id
        end
        it_behaves_like "operation without team privilege", klass
      end
      context "with a member of the group which owns the recipe" do
        before do
          sign_in user2
          g_recipe.owner.add_editor user2
          xhr :delete, :destroy, group_id: g_recipe.owner.id, recipe_id: g_recipe.id,
            id: send("g_#{klass}1").id
        end
        it_behaves_like "success"
      end
    end
  end
end
