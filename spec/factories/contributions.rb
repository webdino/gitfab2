FactoryGirl.define do
  factory :contribution, class: Contribution do
    association :contributor, factory: :user

    after(:build) do |contribution|
      contributable = contribution.contributable || FactoryGirl.build(:user_project)
      contributable.contributions << contribution
      contributable.save!
    end

  end
end
