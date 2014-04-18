require "spec_helper"

describe WaysController do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:recipe1){FactoryGirl.create :recipe, user: user1}
  let(:status){FactoryGirl.create :status, recipe: recipe1}
  let(:way){FactoryGirl.create :way, status: status}
  let(:valid_attributes){{name: "name", description: "description"}}

  describe "POST create" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        xhr :post, :create, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :post, :create, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, way: valid_attributes
      end
      it_behaves_like "operation without team privilege", :way

    end
    context "with a member of the group which owns the recipe" do
      let(:group){FactoryGirl.create :group, creator: user1}
      before do
        controller.stub(:current_user).and_return user2
        group.add_editor user2
        recipe1.update_attributes group_id: group.id
        xhr :post, :create, group_id: group.id, recipe_id: recipe1.id,
          status_id: status.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "PATCH update" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        xhr :patch, :update, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :patch, :update, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
    context "with a member of the group which owns the recipe" do
      let(:group){FactoryGirl.create :group, creator: user1}
      before do
        controller.stub(:current_user).and_return user2
        group.add_editor user2
        recipe1.update_attributes group_id: group.id
        xhr :patch, :update, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id, way: valid_attributes
      end
      it_behaves_like "success"
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        xhr :delete, :destroy, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        xhr :delete, :destroy, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id
      end
      it_behaves_like "operation without team privilege", :way
    end
    context "with a member of the group which owns the recipe" do
      let(:group){FactoryGirl.create :group, creator: user1}
      before do
        controller.stub(:current_user).and_return user2
        group.add_editor user2
        recipe1.update_attributes group_id: group.id
        xhr :delete, :destroy, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status.id, id: way.id
      end
      it_behaves_like "success"
    end
  end
end
