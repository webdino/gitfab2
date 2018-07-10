# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    association :project, factory: :user_project
  end
end
