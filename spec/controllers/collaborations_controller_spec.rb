# frozen_string_literal: true

describe CollaborationsController, type: :controller do
  render_views

  describe 'POST create' do
    subject do
      post :create,
        params: { owner_name: project.owner, project_id: project, collaborator_name: collaborator_name },
        xhr: true
    end

    let(:project) { FactoryBot.create(:project) }

    before { sign_in(project.owner) }

    context 'with valid params' do
      let(:collaborator_name) { FactoryBot.create(:user).slug }
      it do
        is_expected.to be_successful
                  .and render_template(:create)
      end
      it { expect{ subject }.to change{ Collaboration.count }.by(1) }
    end

    context 'with invalid params' do
      let(:collaborator_name) { 'not_exist' }
      it do
        is_expected.to have_http_status(:bad_request)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: false })
      end
      it { expect{ subject }.not_to change{ Collaboration.count } }
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: collaboration.id }, xhr: true }
    let(:collaboration) { FactoryBot.create(:collaboration) }
    before { sign_in(collaboration.owner) }

    context 'user can destroy a collaboration' do
      it do
        is_expected.to be_successful
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: true, id: collaboration.id })
      end
      it { expect{ subject }.to change{ Collaboration.count }.by(-1) }
    end

    context 'user cannot destroy a collaboration' do
      before { collaboration.project.update!(is_deleted: true) }

      it do
        is_expected.to have_http_status(:bad_request)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: false })
      end
      it { expect{ subject }.not_to change{ Collaboration.count } }
    end
  end
end
