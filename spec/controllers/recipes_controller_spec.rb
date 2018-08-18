# frozen_string_literal: true

describe RecipesController, type: :controller do
  describe "PATCH #update" do
    subject do
      patch :update,
        params: {
          owner_name: project.owner,
          project_id: project,
          recipe: {
            states_attributes: [
              { id: card1.id, position: 3 },
              { id: card2.id, position: 2 },
              { id: card3.id, position: 1 }
            ]
          }
        },
        xhr: true
    end

    let!(:project) { FactoryBot.create(:project, updated_at: 1.day.ago) }
    let(:card1) { project.recipe.states.create!(description: 'foo', position: 1) }
    let(:card2) { project.recipe.states.create!(description: 'foo', position: 2) }
    let(:card3) { project.recipe.states.create!(description: 'foo', position: 3) }

    before { sign_in(project.owner) }

    it do
      subject
      expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true })
    end

    it "updates card positions" do
      subject
      aggregate_failures do
        expect(card1.reload.position).to eq 3
        expect(card2.reload.position).to eq 2
        expect(card3.reload.position).to eq 1
      end
    end

    it "updates project's updated_at" do
      expect{ subject }.to change{ project.reload.updated_at }
    end
  end
end
