require "spec_helper"

describe RecipesController, type: :controller do
  disconnect_sunspot
  render_views

  let(:u_project){FactoryGirl.create :user_project}
  let(:g_project){FactoryGirl.create :group_project}
  let(:state){FactoryGirl.build :state}
  let(:transition){FactoryGirl.build :transition}
  let(:annotation){FactoryGirl.build :annotation}

  subject{response}

  shared_context "with a user project" do
    let(:project){u_project}
  end
  shared_context "with a group project" do
    let(:project){u_project}
  end

  describe "GET show" do
    shared_examples "a request rendering 'show' template" do
      before do
        get :show, owner_name: project.owner.name, project_id: project.name
      end
      it{should render_template :show}
    end
    include_context "with a user project" do
      include_examples "a request rendering 'show' template"
    end
    include_context "with a group project" do
      include_examples "a request rendering 'show' template"
    end
  end

  describe "PATCH update" do
    shared_examples "a request to re-order recipe_cards" do
      let(:card1){project.recipe.recipe_cards.create description: "foo", position: 1}
      let(:card2){project.recipe.recipe_cards.create description: "foo", position: 2}
      let(:card3){project.recipe.recipe_cards.create description: "foo", position: 3}
      before do
        xhr :patch, :update, user_id: project.owner.name, project_id: project.name,
          recipe: {recipe_cards_attributes: [
            {id: card1.id, position: 3},
            {id: card2.id, position: 2},
            {id: card3.id, position: 1}]}
        card1.reload
        card2.reload
        card3.reload
      end
      it{should render_template :update}
      it{expect(card1.position).to be 3}
      it{expect(card2.position).to be 2}
      it{expect(card3.position).to be 1}
    end
    include_context "with a user project" do
      include_examples "a request to re-order recipe_cards"
    end
    include_context "with a group project" do
      include_examples "a request to re-order recipe_cards"
    end
  end
end
