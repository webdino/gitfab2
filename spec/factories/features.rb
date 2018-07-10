# frozen_string_literal: true

FactoryBot.define do
  factory :feature do
    sequence(:name) { |n| "feature#{n}" }
  end
end
