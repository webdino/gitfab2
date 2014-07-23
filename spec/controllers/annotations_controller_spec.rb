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
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      xhr :get, :new, owner_name: user.id, project_id: project.id, transition_id: transition.id
    end
    it{should render_template :new}
  end

  describe "GET edit" do
    before do
      sign_in user
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :get, :edit, owner_name: user.id, project_id: project.id,
        transition_id: transition.id, id: annotation.id
    end
    it{should render_template :edit}
  end

  describe "POST create" do
    before do
      sign_in user
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      xhr :post, :create, user_id: user.id, project_id: project.id,
        transition_id: transition.id, annotation: {description: "ann"}
    end
    it{should render_template :transition_annotation}
  end

  describe "PATCH update" do
    before do
      sign_in user
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :patch, :update, user_id: user.id, project_id: project.id,
        transition_id: transition.id, id: annotation.id, annotation: {description: "_ann"}
    end
    it{should render_template :transition_annotation}
  end

  describe "DELETE destroy" do
    before do
      sign_in user
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :delete, :destroy, owner_name: user.id, project_id: project.id,
        transition_id: transition.id, id: annotation.id
    end
    it{should render_template :destroy}
  end
end
