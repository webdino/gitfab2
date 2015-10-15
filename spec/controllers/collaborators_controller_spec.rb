require "spec_helper"

describe CollaboratorsController, type: :controller do
  disconnect_sunspot
  render_views

  subject{response}

  let(:project){FactoryGirl.create :user_project}
  let(:user){FactoryGirl.create :user}
  let(:user_2){FactoryGirl.create :user}

  describe "GET index" do
    before{get :index, owner_name: project.owner.name, project_id: project.id}
    it{should render_template :index}
  end


  describe 'POST create' do
    context 'for user project' do
      context 'with valid parameters' do
        before do
          sign_in project.owner
          post :create, user_id: project.owner.id, project_id: project.id, collaborator_name: user_2.slug
        end
        it{should render_template :create}
      end
      context 'with invalid parameters' do
        before do
          sign_in project.owner
          post :create, user_id: project.owner.id, project_id: project.id, collaborator_name: 'unknownuser'
        end
        it{expect render_template 'errors/failed', status: 400}
      end
    end
  end

end
