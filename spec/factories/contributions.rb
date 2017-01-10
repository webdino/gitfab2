FactoryGirl.define do
  factory :contribution, class: Contribution do
    contributor :user
    contributable :project
  end
end
