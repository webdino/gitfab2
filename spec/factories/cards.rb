# frozen_string_literal: true
# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  annotatable_type :string(255)
#  description      :text(4294967295)
#  oldid            :string(255)
#  position         :integer          default(0), not null
#  title            :string(255)
#  type             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  annotatable_id   :integer
#  note_id          :integer
#  project_id       :integer
#  recipe_id        :integer
#
# Indexes
#
#  index_cards_annotatable  (annotatable_type,annotatable_id)
#  index_cards_note_id      (note_id)
#  index_cards_project_id   (project_id)
#  index_cards_recipe_id    (recipe_id)
#
# Foreign Keys
#
#  fk_cards_note_id     (note_id => notes.id)
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

FactoryBot.define do
  factory :card do
    type Card.name
    description 'description'
  end

  factory :note_card, class: Card::NoteCard, parent: :card do
    type Card::NoteCard.name
    # title, descriptionはpresence: true
    sequence(:title) { |n| "NoteCard #{n}" }
    sequence(:description) { |n| "Description for NoteCard #{n}" }
    note
  end

  factory :annotation, class: Card::Annotation, parent: :card do
    type Card::Annotation.name
    sequence(:title) { |n| "Annotation #{n}" }

    after(:build) do |annotation|
      # TODO: annotation.annotatable がnilであることを許容するのか要確認
      annotatable = annotation.annotatable || FactoryBot.build(:state)
      annotatable.annotations << annotation
      annotatable.save!
    end
  end

  factory :recipe_card, class: Card::RecipeCard, parent: :card do
    type Card::RecipeCard.name
    sequence(:title) { |n| "RecipeCard #{n}" }
    recipe
  end

  factory :state, class: Card::State, parent: :card do
    type Card::State.name
    sequence(:title) { |n| "State #{n}" }
    recipe
  end

  factory :usage, class: Card::Usage, parent: :card do
    type Card::Usage.name
    sequence(:title) { |n| "Usage #{n}" }
    association :project, factory: :user_project
  end
end
