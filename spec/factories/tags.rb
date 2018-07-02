# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag#{n}" }
    user
    association :taggable, factory: :user_project
  end
end
