FactoryGirl.define do
  factory :card do
    type Card.name
    description "description"

    factory :note_card, class: Card::NoteCard do
      type Card::NoteCard.name
      # title, descriptionはpresence: true
      sequence(:title) { |n| "NoteCard #{n}" }
      sequence(:description) { |n| "Description for NoteCard #{n}" }
      note
    end

    factory :annotation, class: Card::Annotation do
      type Card::Annotation.name
      sequence(:title) { |n| "Annotation #{n}" }

      after(:build) do |annotation|
        # TODO: annotation.annotatable がnilであることを許容するのか要確認
        # TODO: ファイル名は複数形のほうが良いか
        annotatable = annotation.annotatable || FactoryGirl.build(:state)
        annotatable.annotations << annotation
        annotatable.save!
      end
    end

    factory :recipe_card, class: Card::RecipeCard do
      type Card::RecipeCard.name
      sequence(:title) { |n| "RecipeCard #{n}" }
      recipe

      after(:create) do |recipe_card|
        FactoryGirl.create(:annotation, annotatable: recipe_card)
        FactoryGirl.create(:annotation, annotatable: recipe_card)
        FactoryGirl.create(:annotation, annotatable: recipe_card)
        FactoryGirl.create(:annotation, annotatable: recipe_card)
        FactoryGirl.create(:annotation, annotatable: recipe_card)

        # 順番変更のテストのため
        # 順番がID通りにならないようにする
        recipe_card.annotations.to_a.shuffle.
          each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }
        recipe_card.annotations.to_a.shuffle.
          each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }

        recipe_card.annotations(true)
      end
    end

    factory :state, class: Card::State do
      type Card::State.name
      sequence(:title) { |n| "State #{n}" }
      recipe

      after(:create) do |state|
        FactoryGirl.create(:annotation, annotatable: state)
        FactoryGirl.create(:annotation, annotatable: state)
        FactoryGirl.create(:annotation, annotatable: state)
        FactoryGirl.create(:annotation, annotatable: state)
        FactoryGirl.create(:annotation, annotatable: state)

        # 順番変更のテストのため
        # 順番がID通りにならないようにする
        state.annotations.to_a.shuffle.
          each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }
        state.annotations.to_a.shuffle.
          each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }

        state.annotations(true)
      end
    end

    factory :usage, class: Card::Usage do
      type Card::Usage.name
      sequence(:title) { |n| "Usage #{n}" }
      association :project, factory: :user_project
    end
  end
end
