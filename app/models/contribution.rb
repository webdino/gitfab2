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

class Contribution < ActiveRecord::Base
  belongs_to :contributor, class_name: 'User', required: true
  # TODO: required: true を付けられるかどうか要検討
  belongs_to :contributable, polymorphic: true
end
