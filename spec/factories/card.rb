FactoryGirl.define do
  factory :card do
    _type Card.name
    description "description"

    factory :note_card, class: Card::NoteCard do
      _type Card::NoteCard.name
      note
    end

    factory :annotation, class: Card::Annotation do
      _type Card::Annotation.name

      after(:build) do |annotation|
        annotatable = annotation.annotatable || FactoryGirl.build(:note_card)
        annotatable.annotations << annotation
        annotatable.save!
      end
    end

    factory :recipe_card, class: Card::RecipeCard do
      _type Card::RecipeCard.name
      recipe
    end

    factory :state, class: Card::State do
      _type Card::State.name
      recipe
    end

    factory :usage, class: Card::Usage do
      _type Card::Usage.name
      association :project, factory: :user_project
    end
  end
end
