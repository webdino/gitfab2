# frozen_string_literal: true

FactoryGirl.define do
  factory :collaboration do
    association :project, factory: :user_project
    association :owner, factory: :user
  end
end
