# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    association :liker, factory: :user
    association :likable, factory: :user_project
  end
end
