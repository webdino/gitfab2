require "spec_helper"

describe StatesController, type: :controller do
  disconnect_sunspot
  render_views

  let(:project){FactoryGirl.create :user_project}
  let(:state){project.recipe.recipe_cards.create _type: Card::State.name, description: "foo"}
  let(:new_state){FactoryGirl.build :state}

  subject{response}

  #FIXME: #445 fix GET new
  # describe "GET new" do
  #   before do
  #     xhr :get, :new, owner_name: project.owner.name, project_id: project.name
  #   end
  #   it{should render_template :_card_form}
  # end

  describe "GET edit" do
    before do
      xhr :get, :edit, owner_name: project.owner.name, project_id: project.name, id: state.id
    end
    it{should render_template :edit}
  end

  describe "POST create" do
    before do
      xhr :post, :create, user_id: project.owner.name, project_id: project.name
      project.reload
    end
    it{should render_template :create}
    it{expect(project.recipe).to have(1).recipe_cards}
  end

  describe "PATCH update" do
    context "when updating the card itself" do
      before do
        xhr :patch, :update, user_id: project.owner.name,
          project_id: project.name, id: state.id
      end
      it{should render_template :update}
    end
  end

  describe "DELETE destroy" do
    before do
      xhr :delete, :destroy, owner_name: project.owner.name,
        project_id: project.name, id: state.id
    end
    it{should render_template :destroy}
  end
end
