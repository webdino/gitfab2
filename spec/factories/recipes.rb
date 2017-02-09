FactoryGirl.define do
  factory :recipe do
    association :project, factory: :user_project

    after(:create) do |recipe|
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)
      FactoryGirl.create(:state, recipe: recipe)

      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)
      FactoryGirl.create(:recipe_card, recipe: recipe)
    end
  end
end
