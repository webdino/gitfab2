# frozen_string_literal: true

describe AnnotationsController, type: :controller do
  render_views

  let(:project) { FactoryBot.create :user_project }
  let(:user) { project.owner }

  subject { response }

  describe 'GET #new' do
    before do
      sign_in user
      state = project.states.create type: Card::State.name, description: 'foo'
      get :new, params: { owner_name: user, project_id: project, state_id: state.id }, xhr: true
    end
    it { is_expected.to render_template :new }
  end

  describe 'GET #edit' do
    before do
      sign_in user
      state = project.states.create type: Card::State.name, description: 'foo'
      annotation = state.annotations.create description: 'ann'
      get :edit, params: {
        owner_name: user, project_id: project, state_id: state.id, id: annotation.id
      }, xhr: true
    end
    it { is_expected.to render_template :edit }
  end

  describe 'GET #show' do
    before do
      sign_in user
      state = project.states.create type: Card::State.name, description: 'foo'
      annotation = state.annotations.create description: 'ann'
      get :show,
        params: { owner_name: user, project_id: project, state_id: state.id, id: annotation.id },
        xhr: true
    end
    it { is_expected.to render_template :show }
  end

  describe 'POST #create' do
    describe 'with correct parameters' do
      before do
        sign_in user
        state = project.states.create type: Card::State.name, description: 'foo'
        post :create,
          params: { owner_name: user, project_id: project, state_id: state.id, annotation: { description: 'ann' } },
          xhr: true
      end
      it { is_expected.to render_template :create }
    end
  end

  describe 'PATCH #update' do
    describe 'with correct parameters' do
      before do
        sign_in user
        state = project.states.create type: Card::State.name, description: 'foo'
        annotation = state.annotations.create description: 'ann'
        patch :update,
          params: {
            owner_name: user, project_id: project, state_id: state.id,
            id: annotation.id, annotation: { description: '_ann' }
          },
          xhr: true
      end
      it { is_expected.to render_template :update }
    end
    describe 'with incorrect parameters' do
      before do
        sign_in user
        state = project.states.create type: Card::State.name, description: 'foo'
        annotation = state.annotations.create description: 'ann'
        patch :update,
          params: {
            owner_name: user, project_id: project, state_id: state.id,
            id: annotation.id, annotation: { type: nil, description: '_ann' }
          },
          xhr: true
      end
      it { expect(response.status).to eq(400) }
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in user
      state = project.states.create type: Card::State.name, description: 'foo'
      annotation = state.annotations.create description: 'ann'
      delete :destroy,
        params: { owner_name: user, project_id: project, state_id: state.id, id: annotation.id },
        xhr: true
    end
    it {  expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true }) }
  end

  describe 'POST #to_state' do
    # TODO: #1366 change #to_state route
    # describe "with correct parameters" do
    #   before do
    #     sign_in user
    #     state = project.states.create type: Card::State.name, description: "foo"
    #     annotation = state.annotations.create description: "ann"
    #     get :to_state,
    #       params: { owner_name: user.slug, project_id: project, state_id: state.id, annotation_id: annotation.id },
    #       xhr: true
    #   end
    #   it{expect(project.states.first.annotations.length).to eq(0)}
    # end
    describe 'with incorrect parameters' do
      before do
        sign_in user
        state = project.states.create type: Card::State.name, description: 'foo'
        state.annotations.create description: 'ann'
        get :to_state,
          params: { owner_name: user.slug, project_id: project, state_id: state.id, annotation_id: 'unexisted_id' },
          xhr: true
      end
      it { expect(response.status).to eq(404) }
      it { expect(response).to render_template(layout: false) }
    end
  end

  # TODO: create update_contribution spec
  describe 'update_contribution' do
    describe 'save_current_users_contribution' do
    end
    describe 'create_new_contribution' do
    end
  end
end
