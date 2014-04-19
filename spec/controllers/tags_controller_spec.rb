require "spec_helper"

describe TagsController do
  disconnect_sunspot
  render_views

  let(:recipe){FactoryGirl.create :user_recipe}
  let(:valid_attributes){{name: "tag1"}}

  describe "POST create" do

    context "when user logged in" do
      before do
        controller.stub(:current_user).and_return recipe.owner
        xhr :post, :create, user: recipe.owner, recipe_id: recipe.id,
          tag: valid_attributes
      end
      it_behaves_like "success"
    end

    context "when user not logged in" do
      before do
        xhr :post, :create, user: recipe.owner, recipe_id: recipe.id,
          tag: valid_attributes
      end
      it_behaves_like "success"
    end
  end
end
