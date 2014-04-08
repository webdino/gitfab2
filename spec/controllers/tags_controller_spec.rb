require "spec_helper"

describe TagsController do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:recipe1){FactoryGirl.create :recipe, user_id: user1.id}
  let(:valid_attributes){{name: "tag1"}}

  describe "POST create" do

    let!(:num_tags){Tag.count}
    shared_examples "creating a new tag" do
      subject{Tag.count}
      it{should be num_tags + 1}
    end

    context "when user logged in" do
      before do
        controller.stub(:current_user).and_return user1
        post :create, user: user1, recipe_id: recipe1.id,
          tag: valid_attributes, format: :json
      end
      it_behaves_like "success"
      it_behaves_like "creating a new tag"
    end

    context "when user not logged in" do
      before do
        post :create, user: user1, recipe_id: recipe1.id,
          tag: valid_attributes, format: :json
      end
      it_behaves_like "success"
      it_behaves_like "creating a new tag"
    end
  end
end
