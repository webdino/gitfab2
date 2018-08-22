# frozen_string_literal: true

describe StatesController, type: :controller do
  render_views

  let(:project) { FactoryBot.create :user_project }
  let(:state) { project.recipe.states.create type: Card::State.name, description: 'foo' }
  let(:new_state) { FactoryBot.build :state }

  subject { response }

  describe 'GET new' do
    before do
      sign_in project.owner
      get :new, params: { owner_name: project.owner, project_id: project.name }, xhr: true
    end
    it { is_expected.to render_template :_card_form }
  end

  describe 'GET show' do
    before do
      get :show, params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
    end
    it { is_expected.to render_template :show, formats: :json }
  end

  describe 'GET edit' do
    before do
      sign_in project.owner
      get :edit, params: { owner_name: project.owner, project_id: project, id: state }, xhr: true
    end
    it { is_expected.to render_template :edit }
  end

  describe 'POST create' do
    context 'with proper values' do
      before do
        sign_in project.owner
        post :create,
          params: {
            owner_name: project.owner, project_id: project,
            state: { type: Card::State.name, title: 'foo', description: 'bar' }
          },
          xhr: true
        project.reload
      end
      it { is_expected.to render_template :create }
      it 'has 1 state' do
        expect(project.states.count).to eq 1
      end
    end
    context 'with invalid values' do
      before do
        sign_in project.owner
        post :create,
          params: {
            owner_name: project.owner, project_id: project,
            state: { type: '', title: 'foo', description: 'bar' }
          },
          xhr: true
      end
      it { expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false }) }
    end
  end

  describe 'PATCH update' do
    context 'when updating the card itself' do
      let!(:state) { project.recipe.states.create type: Card::State.name, description: 'foo' }

      before do
        sign_in project.owner
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { title: 'new_title', description: 'new_desc' }
          },
          xhr: true
      end
      it 'should have new title and new description' do
        state.reload
        expect(state.title).to eq 'new_title'
        expect(state.description).to eq 'new_desc'
      end
      it { is_expected.to render_template :update }
    end
    context 'with invalid values' do
      before do
        sign_in project.owner
        patch :update,
          params: {
            owner_name: project.owner, project_id: project.id, id: state.id,
            state: { type: '', title: 'foo', description: 'bar' }
          },
          xhr: true
      end
      it { expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false }) }
    end
  end

  describe 'DELETE destroy' do
    context 'by who can manage the state' do
      before do
        sign_in project.owner
        delete :destroy,params: { owner_name: project.owner, project_id: project.name, id: state.id }, xhr: true
      end
      it { expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true }) }
    end
  end

  describe 'POST to_annotation' do
    let(:state_2) { project.recipe.states.create type: Card::State.name, description: 'bar' }
    before do
      sign_in project.owner
      post :to_annotation,
        params: { owner_name: project.owner, project_id: project.name, state_id: state_2.id, dst_state_id: state.id },
        xhr: true
      project.reload
    end
    it 'creates an annotation from a state' do
      aggregate_failures '1 state, 1 annotation' do
        expect(project.states.count).to eq 1
        expect(project.states.first.annotations.count).to eq 1
      end
    end
  end
end
