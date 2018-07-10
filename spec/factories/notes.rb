# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    association :project, factory: :user_project
    num_cards 0
  end
end
