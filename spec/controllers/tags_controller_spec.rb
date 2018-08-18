# frozen_string_literal: true

describe TagsController, type: :controller do
  render_views

  let(:user) { FactoryBot.create :user }
  let(:project) { FactoryBot.create :user_project }

  before { sign_in user }

  describe 'POST create' do
    subject do
      post :create,
        params: { owner_name: project.owner, project_id: project, tag: { name: tag_name } },
        xhr: true
    end
    let(:tag_name) { 'new_tag_name' }

    it do
      is_expected.to have_http_status(200)
                .and render_template(:create)
    end
    it { expect{ subject }.to change{ project.reload.tags.count }.by(1) }
    it do
      subject
      expect(project.reload.draft).to include(tag_name)
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: tag.id }, xhr: true }

    let!(:tag) { project.tags.create!(name: 'tag-to-be-deleted', user: user) }

    it do
      is_expected.to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to eq({ success: true })
    end
    it { expect{ subject }.to change{ project.reload.tags.count }.by(-1) }
    it do
      subject
      expect(project.reload.draft).not_to include('tag-to-be-deleted')
    end
  end
end
