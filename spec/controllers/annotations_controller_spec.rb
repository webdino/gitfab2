require "spec_helper"

describe AnnotationsController, type: :controller do
  let(:project){FactoryGirl.create :user_project}
  let(:user){project.owner}

  subject{response}

  describe "GET new" do
    before do
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      xhr :get, :new, user_id: user.id, project_id: project.id,
        recipe_card_id: transition.id
    end
    it{should render_template :new}
  end

  describe "GET edit" do
    before do
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :get, :edit, user_id: user.id, project_id: project.id,
        recipe_card_id: transition.id, id: annotation.id
    end
    it{should render_template :edit}
  end

  describe "POST create" do
    before do
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      xhr :post, :create, user_id: user.id, project_id: project.id,
        recipe_card_id: transition.id, annotation: {description: "ann"}
    end
    it{should render_template :create}
  end

  describe "PATCH update" do
    before do
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :patch, :update, user_id: user.id, project_id: project.id,
        recipe_card_id: transition.id, id: annotation.id, annotation: {description: "_ann"}
    end
    it{should render_template :update}
  end

  describe "DELETE destroy" do
    before do
      transition = project.recipe.recipe_cards.create _type: Card::Transition.name, description: "foo"
      annotation = transition.annotations.create description: "ann"
      xhr :delete, :destroy, user_id: user.id, project_id: project.id,
        recipe_card_id: transition.id, id: annotation.id
    end
    it{should render_template :destroy}
  end
end
