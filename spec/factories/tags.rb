# frozen_string_literal: true

FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "Tag#{n}" }
    user
    association :taggable, factory: :user_project
  end
end
