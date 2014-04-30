require "spec_helper"

describe LikesController do
  disconnect_sunspot
  render_views

  let(:user){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :user_recipe}
  let(:like){FactoryGirl.create :like, valid_attributes}
  let(:valid_attributes){{voter_id: user.id, votable_id: recipe.id, votable_type: recipe.class.name}}

  describe "POST create" do
    context "when user logged in" do
      before do
        sign_in user
        xhr :post, :create, like: valid_attributes
      end
      it_behaves_like "success"
    end

    context "when user not logged in" do
      before do
        xhr :post, :create, like: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "DELETE destroy" do
    context "when user logged in" do
      before do
        sign_in user
        xhr :delete, :destroy, id: like.id,
          like: {votable_id: like.votable.id, votable_type: like.votable.class.name}
      end
      it_behaves_like "success"
    end

    context "when user not logged in" do
      before do
        xhr :delete, :destroy, id: like.id,
          like: {votable_id: like.votable.id, votable_type: like.votable.class.name}
      end
      it_behaves_like "unauthorized"
    end
  end
end
