require "spec_helper"

describe CollaborationsController do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group1){FactoryGirl.create :group, creator: user1}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:g_recipe){FactoryGirl.create :group_recipe}
  let(:collaboration){FactoryGirl.create :collaboration, user: user1, recipe: recipe}
  let(:g_collaboration){FactoryGirl.create :collaboration, group: group1, recipe: recipe}
  let(:valid_attributes){{user_id: user2.id, recipe_id: recipe.id}}
  let(:g_valid_attributes){{user_id: user1.id, recipe_id: g_recipe.id}}

  describe "POST create" do
    before do
      controller.stub(:current_user).and_return recipe.owner
      xhr :post, :create, user_id: recipe.owner.id, recipe_id: recipe.id,
        collaboration: collaboration_params
    end
    context "for user recipe" do
      context "with valid params" do
        let(:collaboration_params){valid_attributes}
        it_behaves_like "success"
        it_behaves_like "render template", "create"
      end
      context "with invalid params" do
        let(:collaboration_params){{user_id: nil}}
        it_behaves_like "success"
        it_behaves_like "render template", "failed"
      end
    end
    context "for group recipe" do
      context "with valid params" do
        let(:collaboration_params){g_valid_attributes}
        it_behaves_like "success"
        it_behaves_like "render template", "create"
      end
      context "with invalid params" do
        let(:collaboration_params){{group_id: nil}}
        it_behaves_like "success"
        it_behaves_like "render template", "failed"
      end
    end
  end

  describe "DELETE destroy" do
    before do
      controller.stub(:current_user).and_return user1
      xhr :delete, :destroy, user_id: recipe.owner.id, recipe_id: recipe.id,
        id: collaboration.id
    end
    it_behaves_like "render template", "destroy"
  end
end
