FactoryGirl.define do
  factory :card do
    type Card.name
    description "description"

    factory :note_card, class: Card::NoteCard do
      type Card::NoteCard.name
      note
    end

    factory :annotation, class: Card::Annotation do
      type Card::Annotation.name

      after(:build) do |annotation|
        annotatable = annotation.annotatable || FactoryGirl.build(:note_card)
        annotatable.annotations << annotation
        annotatable.save!
      end
    end

    factory :recipe_card, class: Card::RecipeCard do
      type Card::RecipeCard.name
      recipe
    end

    factory :state, class: Card::State do
      type Card::State.name
      recipe
    end

    factory :usage, class: Card::Usage do
      type Card::Usage.name
      association :project, factory: :user_project
    end
  end
end
