# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  oldid      :string(255)
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

class Like < ActiveRecord::Base
  include Contributable

  belongs_to :user, required: true
  belongs_to :project, required: true, counter_cache: :likes_count
  validates :user_id, uniqueness: { scope: :project }

  class << self
    def updatable_columns
      [:_destroy, :id, :user_id]
    end
  end
end
