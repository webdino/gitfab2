# frozen_string_literal: true

FactoryGirl.define do
  factory :recipe do
    association :project, factory: :user_project

    after(:create) do |recipe|
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)

      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)

      # 順番変更のテストのため
      # 順番がID通りにならないようにする
      recipe.states.to_a.shuffle
            .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }
      recipe.recipe_cards.to_a.shuffle
            .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }

      recipe.states(true)
      recipe.recipe_cards(true)
    end
  end
end
