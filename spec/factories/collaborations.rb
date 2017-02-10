# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    association :project, factory: :user_project
    association :owner, factory: :user
  end
end
