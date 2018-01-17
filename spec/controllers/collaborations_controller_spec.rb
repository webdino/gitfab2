require "spec_helper"

describe CollaborationsController, type: :controller do
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}
  let(:group1){FactoryGirl.create :group, creator: user1}
  let(:project){FactoryGirl.create :user_project}
  let(:valid_attributes){{project_id: project.id}}

  describe "POST create" do
    before do
      sign_in project.owner
      xhr :post, :create, user_id: project.owner.to_param,
        collaboration: collaboration_params
    end
    context "for user project" do
      context "with valid params" do
        let(:collaboration_params){valid_attributes}
        it_behaves_like "success"
        it_behaves_like "render template", "create"
      end
      context "with invalid params" do
        let(:collaboration_params){{}}
        it_behaves_like "unauthorized"
      end
    end
  end

  describe "DELETE destroy" do
    before do
      collaboration = user1.collaborations.create project_id: project.id
      sign_in user1
      xhr :delete, :destroy, user_id: user1.to_param, project_id: project.id,
        id: collaboration.id
    end
    it_behaves_like "render template", "destroy"
  end
end
