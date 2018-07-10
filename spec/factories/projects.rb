# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :owner, factory: :user
    name { "project-#{SecureRandom.hex 10}" }
    title { SecureRandom.uuid }
    description { SecureRandom.uuid }
    is_deleted false

    trait :public do
      is_private false
    end

    trait :private do
      is_private true
    end

    trait :soft_destroyed do
      is_deleted true
    end
  end

  factory :user_project, parent: :project do
    association :owner, factory: :user
  end

  factory :group_project, parent: :project do
    association :owner, factory: :group
  end
end
