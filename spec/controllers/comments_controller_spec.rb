require "spec_helper"

describe CommentsController do
  disconnect_sunspot
  render_views

  let(:user){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :recipe, user_id: user.id}
  let(:comment){FactoryGirl.create :comment, valid_attributes}
  let(:valid_attributes) do
    {
      title: "title",
      comment: "comment",
      commentable_id: recipe.id,
      commentable_type: recipe.class.name,
      user_id: user.id
    }
  end

  describe "POST create" do
    context "when user logged in" do
      before do
        controller.stub(:current_user).and_return user
        xhr :post, :create, comment: valid_attributes
      end
      it_behaves_like "success"
    end
    context "when user not logged in" do
      before do
        xhr :post, :create, comment: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "PATCH update" do
    context "when user is the owner of the comment" do
      before do
        controller.stub(:current_user).and_return user
        xhr :patch, :update, id: comment.id, comment: valid_attributes
      end
      it_behaves_like "success"
    end
    context "when user isn't the owner of the comment" do
      before do
        xhr :patch, :update, id: comment.id, comment: valid_attributes
      end
      it_behaves_like "unauthorized"
    end
  end

  describe "DELETE destroy" do
    context "when user is the owner of the comment" do
      before do
        controller.stub(:current_user).and_return user
        xhr :delete, :destroy, id: comment.id
      end
      it_behaves_like "success"
    end
    context "when user isn't the owner of the comment" do
      before do
        xhr :delete, :destroy, id: comment.id
      end
      it_behaves_like "unauthorized"
    end
  end
end
