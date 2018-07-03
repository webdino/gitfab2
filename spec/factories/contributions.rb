# frozen_string_literal: true

FactoryBot.define do
  factory :contribution do
    association :contributor, factory: :user

    after(:build) do |contribution|
      # TODO: contribution.contributable がnil を許容するかどうか要確認
      contributable = contribution.contributable || FactoryBot.build(:user_project)
      contributable.contributions << contribution
      contributable.save!
    end
  end
end
