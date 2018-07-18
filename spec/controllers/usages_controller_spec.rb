# frozen_string_literal: true

describe UsagesController, type: :controller do
  render_views

  let(:project) { FactoryBot.create :user_project }
  let(:owner) { project.owner }
  let(:new_usage) { FactoryBot.build :usage }

  subject { response }

  describe 'GET new' do
    before do
      sign_in owner
      get :new, params: { owner_name: owner.to_param, project_id: project }, xhr: true
    end
    it { is_expected.to render_template :new }
  end

  describe 'GET edit' do
    before do
      sign_in owner
      usage = FactoryBot.create(:usage, project: project)
      get :edit, params: { owner_name: owner.to_param, project_id: project, id: usage.id }, xhr: true
    end
    it { is_expected.to render_template :edit }
  end

  describe 'POST create' do
    before do
      sign_in owner
      project.usages.destroy_all
      post :create, params: { user_id: owner.to_param, project_id: project.name, usage: { title: 'title' } }, xhr: true
      project.reload
    end
    it { is_expected.to render_template :create }
    it 'has 1 usage' do
      expect(project.usages.size).to eq 1
    end
  end

  describe 'PATCH update' do
    before do
      sign_in owner
      usage = FactoryBot.create(:usage, project: project, title: 'foo', description: 'bar')
      patch :update,
        params: { user_id: owner.to_param, project_id: project, id: usage.id, usage: { title: 'title' } },
        xhr: true
    end
    it { is_expected.to render_template :update }
  end

  describe 'DELETE destroy' do
    before do
      sign_in owner
      usage = FactoryBot.create(:usage, project: project, title: 'foo', description: 'bar')
      delete :destroy, params: { owner_name: owner.to_param, project_id: project, id: usage.id }, xhr: true
    end
    it { expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true }) }
  end
end
