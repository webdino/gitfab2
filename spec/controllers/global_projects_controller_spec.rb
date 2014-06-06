require "spec_helper"

describe GlobalProjectsController, type: :controller do
#  disconnect_sunspot
  render_views

  describe "GET index" do
    context "without queries" do
      before{get :index}
      it{expect(response).to render_template :index}
    end
    context "with queries" do
      before{get :index, q: "foo"}
      it{expect(response).to render_template :index}
    end
  end
end
