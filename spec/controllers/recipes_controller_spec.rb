# frozen_string_literal: true

describe RecipesController, type: :controller do
  render_views

  let(:u_project) { FactoryBot.create :user_project }
  let(:g_project) { FactoryBot.create :group_project }
  let(:state) { FactoryBot.build :state }
  let(:annotation) { FactoryBot.build :annotation }

  subject { response }

  shared_context 'with a user project' do
    let(:project) { u_project }
  end
  shared_context 'with a group project' do
    let(:project) { g_project }
  end

  describe 'GET show' do
    shared_examples "a request rendering 'show' template" do
      before do
        get :show, owner_name: project.owner.name, project_id: project.name
      end
      it { is_expected.to render_template :show }
    end
    include_context 'with a user project' do
      include_examples "a request rendering 'show' template"
    end
    include_context 'with a group project' do
      include_examples "a request rendering 'show' template"
    end
  end

  describe 'PATCH update' do
    shared_examples 'a request to re-order states' do
      let(:card1) { project.recipe.states.create description: 'foo', position: 1 }
      let(:card2) { project.recipe.states.create description: 'foo', position: 2 }
      let(:card3) { project.recipe.states.create description: 'foo', position: 3 }
      before do
        xhr :patch, :update, user_id: project.owner.name, project_id: project.name,
                             recipe: { states_attributes: [
                               { id: card1.id, position: 3 },
                               { id: card2.id, position: 2 },
                               { id: card3.id, position: 1 }
                             ] }
        card1.reload
        card2.reload
        card3.reload
      end
      it { is_expected.to render_template :update }
      it { expect(card1.position).to be 3 }
      it { expect(card2.position).to be 2 }
      it { expect(card3.position).to be 1 }
    end
    include_context 'with a user project' do
      include_examples 'a request to re-order states'
    end
    include_context 'with a group project' do
      include_examples 'a request to re-order states'
    end
  end
end
