# frozen_string_literal: true

FactoryGirl.define do
  factory :contribution, class: Contribution do
    association :contributor, factory: :user

    after(:build) do |contribution|
      # TODO: contribution.contributable がnil を許容するかどうか要確認
      contributable = contribution.contributable || FactoryGirl.build(:user_project)
      contributable.contributions << contribution
      contributable.save!
    end
  end
end
