require "spec_helper"

describe CollaboratorsController, type: :controller do
  disconnect_sunspot
  render_views

  subject{response}

  let(:project){FactoryGirl.create :user_project}
  let(:user){FactoryGirl.create :user}

  describe "GET index" do
    before{get :index, owner_name: project.owner.name, project_id: project.name}
    it{should render_template :index}
  end
  
end
