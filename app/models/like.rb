# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_likes_likable   (project_id)
#  index_likes_liker_id  (user_id)
#  index_likes_unique    (project_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_likes_liker_id  (user_id => users.id)
#

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :project, counter_cache: :likes_count
  validates :user_id, uniqueness: { scope: :project, case_sensitive: true }
end
