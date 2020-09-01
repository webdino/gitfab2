# frozen_string_literal: true
# == Schema Information
#
# Table name: cards
#
#  id             :integer          not null, primary key
#  comments_count :integer          default(0), not null
#  description    :text(4294967295)
#  position       :integer          default(0), not null
#  title          :string(255)
#  type           :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  project_id     :integer
#  state_id       :integer
#
# Indexes
#
#  index_cards_on_state_id  (state_id)
#  index_cards_project_id   (project_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#

FactoryBot.define do
  factory :card do
    type { Card.name }
    description { Faker::Lorem.paragraph }
  end

  factory :note_card, class: Card::NoteCard, parent: :card do
    type { Card::NoteCard.name }
    # title, descriptionはpresence: true
    title { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    project
  end

  factory :annotation, class: Card::Annotation, parent: :card do
    type { Card::Annotation.name }
    title { Faker::Lorem.word }
    association :state, factory: [:state, :without_annotations]
  end

  factory :state, class: Card::State, parent: :card do
    type { Card::State.name }
    title { Faker::Lorem.word }
    project

    transient do
      annotations_count { rand(0..5) }
    end

    after(:build) do |state, evaluator|
      state.annotations = FactoryBot.build_list(:annotation, evaluator.annotations_count, state: state) unless evaluator.annotations_count.nil?
    end

    trait :without_annotations do
      annotations_count { nil }
    end
  end

  factory :usage, class: Card::Usage, parent: :card do
    type { Card::Usage.name }
    title { Faker::Lorem.word }
    association :project, factory: :user_project
  end
end
