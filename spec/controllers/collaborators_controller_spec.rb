# frozen_string_literal: true

describe CollaboratorsController, type: :controller do
  render_views

  subject { response }

  let(:project) { FactoryBot.create :user_project }
  let(:user) { FactoryBot.create :user }
  let(:user_2) { FactoryBot.create :user }

  describe 'GET index' do
    before { get :index, params: { owner_name: project.owner.name, project_id: project } }
    it { is_expected.to render_template :index }
  end
end
