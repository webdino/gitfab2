# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    association :project, factory: :user_project
    num_cards 0
    after(:create) do |note|
      FactoryBot.create(:note_card, note: note)
      FactoryBot.create(:note_card, note: note)
      FactoryBot.create(:note_card, note: note)
    end
  end
end
