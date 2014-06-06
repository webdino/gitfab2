require "spec_helper"

describe DevelopmentController, type: :controller do
  disconnect_sunspot
  render_views

  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}

  describe "POST su" do
    before do
      sign_in user
      controller.request.stub referer: "/foo.html"
      post :su, user_id: other.id
    end
    it{expect(response).to redirect_to "/foo.html"}
  end
end
