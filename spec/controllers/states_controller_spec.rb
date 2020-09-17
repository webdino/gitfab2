# frozen_string_literal: true

describe StatesController, type: :controller do
  render_views

  describe 'GET new' do
    let(:project) { FactoryBot.create :user_project }

    before { sign_in project.owner }

    it do
      get :new, params: { owner_name: project.owner, project_id: project.name }, xhr: true
      expect(response).to render_template :_card_form
    end
  end

  describe 'GET show' do
    let(:project) { FactoryBot.create :user_project }
    let(:state) { FactoryBot.create(:state, project: project) }

    before { sign_in project.owner }
  
    it do
      get :show, params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
      expect(response).to render_template :show, formats: :json
    end
  end

  describe 'GET edit' do
    let(:project) { FactoryBot.create :user_project }
    let(:state) { FactoryBot.create(:state, project: project) }

    before { sign_in(project.owner) }
  
    it do
      get :edit, params: { owner_name: project.owner, project_id: project, id: state }, xhr: true
      expect(response).to render_template :edit
    end
  end

  describe 'POST create' do
    let(:project) { FactoryBot.create :user_project }
  
    context 'when an owner is signed in' do
      let(:current_user) { project.owner }
      before { sign_in(current_user) }

      context 'with proper values' do
        it do
          post :create,
            params: {
              owner_name: project.owner, project_id: project,
              state: { type: Card::State.name, title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(response).to have_http_status(:ok)
        end

        it do
          post :create,
            params: {
              owner_name: project.owner, project_id: project,
              state: { type: Card::State.name, title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(response).to render_template :create
        end

        it 'has 1 state' do
          expect {
            post :create,
            params: {
              owner_name: project.owner, project_id: project,
              state: { type: Card::State.name, title: 'foo', description: 'bar' }
            },
            xhr: true
          }.to change(project.states, :count).by(1)
        end
      end

      context 'with invalid values' do
        it do
          post :create,
            params: {
              owner_name: project.owner, project_id: project,
              state: { type: '', title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(response).to_not have_http_status(:ok)
        end

        it do
          post :create,
            params: {
              owner_name: project.owner, project_id: project,
              state: { type: '', title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end

    context 'when an user is signed in' do
      let(:current_user) { FactoryBot.create(:user) }
      before { sign_in(current_user) }

      before do
        post :create,
          params: {
            owner_name: project.owner, project_id: project,
            state: { type: Card::State.name, title: 'foo', description: 'bar' }
          },
          xhr: true
        project.reload
      end
      it { expect(response).to_not have_http_status(:ok) }
    end

    context 'when an user is not signed in' do
      before do
        post :create,
          params: {
            owner_name: project.owner, project_id: project,
            state: { type: Card::State.name, title: 'foo', description: 'bar' }
          },
          xhr: true
        project.reload
      end
      it { expect(response).to_not have_http_status(:ok) }
    end
  end

  describe 'PATCH update' do
    let(:project) { FactoryBot.create :user_project }
    let(:state) { FactoryBot.create(:state, project: project) }

    context 'when an owner is signed in' do
      let(:current_user) { project.owner }
      before { sign_in(current_user) }

      it 'should have new title and new description' do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true

        state.reload
        expect(state.title).to eq 'new_title'
        expect(state.description).to eq 'new_desc'
      end

      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
  
        expect(response).to have_http_status(:ok)
      end

      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true

        expect(response).to render_template :update
      end
      
      context 'with invalid values' do
        it do
          patch :update,
            params: {
              owner_name: project.owner, project_id: project.id, id: state.id,
              state: { type: '', title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(response).to_not have_http_status(:ok)
        end
        it do
          patch :update,
            params: {
              owner_name: project.owner, project_id: project.id, id: state.id,
              state: { type: '', title: 'foo', description: 'bar' }
            },
            xhr: true
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end

    context 'when an user is signed in' do
      let(:current_user) { FactoryBot.create(:user) }
      before { sign_in(current_user) }
  
      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
        expect(response).to_not have_http_status(:ok)
      end

      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
        expect(response).to_not render_template :update
      end
    end

    context 'when an user is not signed in' do
      let!(:state) { FactoryBot.create(:state, project: project) }

      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
        expect(response).to_not have_http_status(:ok) 
      end

      it do
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
        expect(response).to_not render_template :update
      end
    end
  end

  describe 'DELETE destroy' do
    let(:project) { FactoryBot.create :user_project }
    let(:state) { FactoryBot.create(:state, project: project) }
  
    context 'when an owner is signed in' do
      let(:current_user) { project.owner }
      before { sign_in(current_user) }

      context 'by who can manage the state' do
        it do
          delete :destroy,params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
          expect(response).to have_http_status(:ok)
        end

        it do
          delete :destroy,params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true })
        end
      end
    end

    context 'when a user is signed in' do
      let(:current_user) { FactoryBot.create(:user) }
      before { sign_in(current_user) }

      context 'by who can manage the state' do
        it do
          delete :destroy,params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
          expect(response).to_not have_http_status(:ok)
        end
      end
    end

    context 'when a user is not signed in' do
      context 'by who can manage the state' do
        it do
          delete :destroy,params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
          expect(response).to_not have_http_status(:ok)
        end
      end
    end
  end

  describe 'POST to_annotation' do
    let(:project) { FactoryBot.create :user_project }
    let!(:state) { FactoryBot.create(:state, project: project) }
    let!(:state_2) { FactoryBot.create(:state, project: project) }

    context 'when an owner is signed in' do
      let(:current_user) { project.owner }

      before { sign_in(current_user) }

      it do
        post :to_annotation,
          params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
          xhr: true
        expect(response).to have_http_status(:ok)
      end

      it 'creates an annotation from a state' do
        expect {
          post :to_annotation,
            params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
            xhr: true
        }.to change(project.states, :count).by(-1)
      end

      it 'creates an annotation from a state' do
        expect {
          post :to_annotation,
            params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
            xhr: true
        }.to change(state.annotations, :count).by(1)
      end
    end

    context 'when a user is signed in' do
      let(:current_user) { FactoryBot.create(:user) }

      before { sign_in(current_user) }

      it do
        post :to_annotation,
          params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
          xhr: true
        expect(response).to_not have_http_status(:ok)
      end
    end

    context 'when a user is not signed in' do
      it do
        post :to_annotation,
          params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
          xhr: true

        expect(response).to_not have_http_status(:ok)
      end
    end
  end
end
