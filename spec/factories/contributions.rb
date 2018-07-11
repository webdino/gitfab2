# frozen_string_literal: true
# == Schema Information
#
# Table name: contributions
#
#  id                 :integer          not null, primary key
#  contributable_type :string(255)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  contributable_id   :integer          not null
#  contributor_id     :integer          not null
#
# Indexes
#
#  index_contributions_contributable   (contributable_type,contributable_id)
#  index_contributions_contributor_id  (contributor_id)
#
# Foreign Keys
#
#  fk_contributions_contributor_id  (contributor_id => users.id)
#

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
