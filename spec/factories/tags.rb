# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "Tag#{n}" }
    user
    association :taggable, factory: :user_project
  end
end
