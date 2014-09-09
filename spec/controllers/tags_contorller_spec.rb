require "spec_helper"

describe TagsController, type: :controller do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}

  describe "POST create" do
    before do
      sign_in user1
      xhr :post, :create, user_id: project.owner.id, project_id: project.id, tag: {name: "foo", user_id: user1.id}
    end
    it_behaves_like "success"
    it_behaves_like "render template", "create"
  end

  describe "DELETE destroy" do
    before do
      tag = project.tags.create
      sign_in user1
      xhr :delete, :destroy, user_id: project.owner.id, project_id: project.id, id: tag.id
    end
    it_behaves_like "render template", "destroy"
  end
end
