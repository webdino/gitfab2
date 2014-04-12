require "spec_helper"

describe TagsController do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:recipe1){FactoryGirl.create :recipe, user_id: user1.id}
  let(:valid_attributes){{name: "tag1"}}

  describe "POST create" do

    context "when user logged in" do
      before do
        controller.stub(:current_user).and_return user1
        xhr :post, :create, user: user1, recipe_id: recipe1.id,
          tag: valid_attributes
      end
      it_behaves_like "success"
    end

    context "when user not logged in" do
      before do
        xhr :post, :create, user: user1, recipe_id: recipe1.id,
          tag: valid_attributes
      end
      it_behaves_like "success"
    end
  end
end
