require "spec_helper"

describe WaysController do
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:recipe1){FactoryGirl.create :recipe, user_id: user1.id}
  let(:status1){FactoryGirl.create :status, recipe_id: recipe1.id}
  let(:way1){FactoryGirl.create :way, status_id: status1.id}
  let(:valid_attributes){FactoryGirl.build(:way).attributes}

  describe "POST create" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        post :create, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        post :create, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
  end

  describe "PATCH update" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        patch :update, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, id: way1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        patch :update, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, id: way1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
  end

  describe "DELETE destroy" do
    context "with owner" do
      before do
        controller.stub(:current_user).and_return user1
        delete :destroy, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, id: way1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
    context "with non owner" do
      before do
        controller.stub(:current_user).and_return user2
        delete :destroy, user_id: user1.id, recipe_id: recipe1.id,
          status_id: status1.id, id: way1.id, way: valid_attributes, format: :json
      end
      it_behaves_like "success"
    end
  end
end
