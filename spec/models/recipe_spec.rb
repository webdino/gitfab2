require "spec_helper"

describe Recipe do
  let(:u_project){FactoryGirl.create :user_project}
  let(:u_project_recipe){u_project.recipe}
  let(:g_project){FactoryGirl.create :group_project}
  let(:g_project_recipe){g_project.recipe}

  describe "#dup_document" do
    context "with a user recipe" do
      it{expect(u_project_recipe.dup_document).to be_a Recipe}
    end
    context "with a group recipe" do
      it{expect(g_project_recipe.dup_document).to be_a Recipe}
    end

    describe 'statesを複製する' do
      let(:recipe) { FactoryGirl.create(:recipe) }
      subject(:dupped_recipe) do
        recipe.dup_document.tap { |obj| obj.save! }
      end
      it '数を維持すること' do
        expect(dupped_recipe.states.size).to eq(recipe.states.size)
      end
      it '順番・内容を維持すること' do
        expect(Card::State.where(id: dupped_recipe.states.pluck(:id)).order(:position).map(&:title)).
          to eq(Card::State.where(id: recipe.states.pluck(:id)).order(:position).map(&:title))
      end
      it '複製であること' do
        expect(dupped_recipe.states.map(&:id)).to_not eq(recipe.states.map(&:id))
      end
    end

    describe 'recipe_cardsを複製しない' do
      let(:recipe) { FactoryGirl.create(:recipe) }
      subject(:dupped_recipe) do
        recipe.dup_document.tap { |obj| obj.save! }
      end
      it '複製先では空であること' do
        expect(recipe.recipe_cards.size).to_not eq(0)
        expect(dupped_recipe.recipe_cards.size).to eq(0)
      end
    end

  end
end
