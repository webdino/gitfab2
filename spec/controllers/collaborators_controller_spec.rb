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

  describe 'POST create' do
    context 'for user project' do
      context 'with valid parameters' do
        before do
          sign_in project.owner
          post :create,
            params: { user_id: project.owner, project_id: project, collaborator_name: user_2.slug },
            xhr: true
        end
        it { is_expected.to render_template :create }
      end
      context 'with invalid parameters' do
        before do
          sign_in project.owner
          post :create,
            params: { user_id: project.owner, project_id: project, collaborator_name: 'unknownuser' },
            xhr: true
        end
        it do
          is_expected.to have_http_status(400)
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end
  end
end
