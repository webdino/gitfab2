# frozen_string_literal: true

FactoryBot.define do
  factory :feature do
    after(:build) do |feature|
      feature.featured_items << FactoryBot.create(:featured_item, feature: feature)
      feature.featured_items << FactoryBot.create(:featured_item, feature: feature)
      feature.featured_items << FactoryBot.create(:featured_item, feature: feature)
    end

    sequence(:name) { |n| "feature#{n}" }
  end
end
