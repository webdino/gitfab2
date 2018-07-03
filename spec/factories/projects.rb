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

    after(:create) do |project|
      FactoryBot.create(:usage, project: project)
      FactoryBot.create(:usage, project: project)
      FactoryBot.create(:usage, project: project)
      FactoryBot.create(:usage, project: project)
      FactoryBot.create(:usage, project: project)

      # 順番変更のテストのため
      # 順番がID通りにならないようにする
      project.usages.to_a.shuffle
             .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }
      project.usages.to_a.shuffle
             .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }

      project.usages.reload
    end

    factory :user_project, class: Project do
      association :owner, factory: :user
    end

    factory :group_project, class: Project do
      association :owner, factory: :group
    end
  end
end
