# frozen_string_literal: true

FactoryGirl.define do
  factory :note do
    association :project, factory: :user_project
    num_cards 0
    after(:create) do |note|
      FactoryGirl.create(:note_card, note: note)
      FactoryGirl.create(:note_card, note: note)
      FactoryGirl.create(:note_card, note: note)
    end
  end
end
