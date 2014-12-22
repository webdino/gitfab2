require "spec_helper"

describe AnnotationsController, type: :controller do
  disconnect_sunspot
  render_views

  let(:project){FactoryGirl.create :user_project}
  let(:user){project.owner}

  subject{response}

  describe "GET new" do
    before do
      sign_in user
      state = project.recipe.states.create _type: Card::State.name, description: "foo"
      xhr :get, :new, owner_name: user.id, project_id: project.id, state_id: state.id
    end
    it{should render_template :new}
  end

  describe "GET edit" do
    before do
      sign_in user
      state = project.recipe.states.create _type: Card::State.name, description: "foo"
      annotation = state.annotations.create description: "ann"
      xhr :get, :edit, owner_name: user.id, project_id: project.id,
        state_id: state.id, id: annotation.id
    end
    it{should render_template :edit}
  end

  describe "POST create" do
    before do
      sign_in user
      state = project.recipe.states.create _type: Card::State.name, description: "foo"
      xhr :post, :create, user_id: user.id, project_id: project.id,
        state_id: state.id, annotation: {description: "ann"}
    end
    it{should render_template :create}
  end

  describe "PATCH update" do
    before do
      sign_in user
      state = project.recipe.states.create _type: Card::State.name, description: "foo"
      annotation = state.annotations.create description: "ann"
      xhr :patch, :update, user_id: user.id, project_id: project.id,
        state_id: state.id, id: annotation.id, annotation: {description: "_ann"}
    end
    it{should render_template :update}
  end

  describe "DELETE destroy" do
    before do
      sign_in user
      state = project.recipe.states.create _type: Card::State.name, description: "foo"
      annotation = state.annotations.create description: "ann"
      xhr :delete, :destroy, owner_name: user.id, project_id: project.id,
        state_id: state.id, id: annotation.id
    end
    it{should render_template :destroy}
  end
end
