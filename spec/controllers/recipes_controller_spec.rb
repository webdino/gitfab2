require "spec_helper"

describe RecipesController, type: :controller do
  disconnect_sunspot
  render_views

  let(:u_project){FactoryGirl.create :user_project}
  let(:g_project){FactoryGirl.create :group_project}
  let(:state){FactoryGirl.build :state}
  let(:transition){FactoryGirl.build :transition}
  let(:annotation){FactoryGirl.build :annotation}

  subject{response}

  shared_context "with a user project" do
    let(:project){u_project}
  end
  shared_context "with a group project" do
    let(:project){u_project}
  end

  describe "GET show" do
    shared_examples "a request rendering 'show' template" do
      before do
        get :show, owner_name: project.owner.name, project_id: project.name
      end
      it{should render_template :show}
    end
    include_context "with a user project" do
      include_examples "a request rendering 'show' template"
    end
    include_context "with a group project" do
      include_examples "a request rendering 'show' template"
    end
  end
end
