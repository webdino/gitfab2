# frozen_string_literal: true

describe Card::RecipeCard do
  it_behaves_like 'Annotable', :recipe_card
  it_behaves_like 'Card', :recipe_card
  it_behaves_like 'Orderable', :recipe_card
  it_behaves_like 'Orderable Scoped incrementation', [:recipe_card], :recipe

  describe '.ordered_by_position' do
    it { expect(Card::RecipeCard).to be_respond_to(:ordered_by_position) }
  end
end
