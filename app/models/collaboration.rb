# == Schema Information
#
# Table name: collaborations
#
#  id         :integer          not null, primary key
#  owner_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#  owner_id   :integer
#  project_id :integer          not null
#
# Indexes
#
#  index_collaborations_owner       (owner_type,owner_id)
#  index_collaborations_project_id  (project_id)
#

class Collaboration < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :project
end
