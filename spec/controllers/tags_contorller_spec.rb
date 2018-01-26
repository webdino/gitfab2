require "spec_helper"

describe TagsController, type: :controller do
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}

  describe "POST create" do
    before do
      sign_in user1
      xhr :post, :create, user_id: project.owner, project_id: project, tag: {name: "foo", user_id: user1.id}
      project.reload
    end
    it_behaves_like "success"
    it { expect(response).to render_template :create }
    it { expect(project.tags.count).to eq 1 }
    it { expect(project.draft).to include("foo") }
  end

  describe "DELETE destroy" do
    before do
      tag = project.tags.create(name: 'tag-to-be-deleted')
      sign_in user1
      xhr :delete, :destroy, user_id: project.owner, project_id: project, id: tag.id
      project.reload
    end
    it { expect(response).to render_template :destroy }
    it { expect(project.tags.count).to eq 0 }
    it { expect(project.draft).not_to include("tag-to-be-deleted") }
  end
end
