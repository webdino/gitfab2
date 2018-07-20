# == Schema Information
#
# Table name: contributions
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  card_id        :integer          not null
#  contributor_id :integer          not null
#
# Indexes
#
#  fk_rails_934cb2529a                 (card_id)
#  index_contributions_contributor_id  (contributor_id)
#
# Foreign Keys
#
#  fk_contributions_contributor_id  (contributor_id => users.id)
#  fk_rails_...                     (card_id => cards.id)
#

class Contribution < ApplicationRecord
  belongs_to :contributor, class_name: 'User', required: true
  belongs_to :card, required: true
end
