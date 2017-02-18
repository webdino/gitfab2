# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name {"project-#{SecureRandom.hex 10}"}
    title {SecureRandom.uuid}
    description {SecureRandom.uuid}
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
      FactoryGirl.create(:usage, project: project)
      FactoryGirl.create(:usage, project: project)
      FactoryGirl.create(:usage, project: project)
      FactoryGirl.create(:usage, project: project)
      FactoryGirl.create(:usage, project: project)

      # 順番変更のテストのため
      # 順番がID通りにならないようにする
      project.usages.to_a.shuffle.
        each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }
      project.usages.to_a.shuffle.
        each_with_index { |s, i| s.tap { s.update_column(:position, i + 1) } }

      project.usages(true)
    end

    factory :user_project, class: Project do |up|
      up.owner {|o| o.association :user}
    end

    factory :group_project, class: Project do |gp|
      gp.owner {|o| o.association :group}
    end
  end
end
