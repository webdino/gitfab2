# frozen_string_literal: true

describe Recipe do
  it_behaves_like 'DraftInterfaceTest', FactoryBot.create(:recipe)

  let(:u_project) { FactoryBot.create :user_project }
  let(:u_project_recipe) { u_project.recipe }
  let(:g_project) { FactoryBot.create :group_project }
  let(:g_project_recipe) { g_project.recipe }

  describe '#dup_document' do
    context 'with a user recipe' do
      it { expect(u_project_recipe.dup_document).to be_a Recipe }
    end
    context 'with a group recipe' do
      it { expect(g_project_recipe.dup_document).to be_a Recipe }
    end

    describe 'statesを複製する' do
      subject(:dupped_recipe) { recipe.dup_document.tap(&:save!) }

      let(:recipe) do
        FactoryBot.create(:recipe) do |recipe|
          FactoryBot.create_list(:state, state_count, recipe: recipe)
        end
      end
      let(:state_count) { 5 }

      it '数を維持すること' do
        expect(dupped_recipe.states.count).to eq(state_count)
      end
      it '順番・内容を維持すること' do
        recipe.states.to_a.shuffle
          .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }
        recipe.states.reload

        actual   = Card::State.where(id: dupped_recipe.states.pluck(:id)).order(:position).map(&:title)
        expected = Card::State.where(id: recipe       .states.pluck(:id)).order(:position).map(&:title)
        expect(actual).to eq(expected)
      end
      it '複製であること' do
        expect(dupped_recipe.states.map(&:id)).to_not eq(recipe.states.map(&:id))
      end
    end
  end
end
