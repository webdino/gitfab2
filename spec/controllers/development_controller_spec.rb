require "spec_helper"

describe DevelopmentController, type: :controller do
  render_views

  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}

  describe "POST su" do
    before do
      sign_in user
      allow(controller.request).to receive(:referer).and_return("/foo.html")
      post :su, user_id: other.id
    end
    it{expect(response).to redirect_to "/foo.html"}
  end
end
