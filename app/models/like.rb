# == Schema Information
#
# Table name: likes
#
#  id           :integer          not null, primary key
#  likable_type :string(255)      not null
#  oldid        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  likable_id   :integer          not null
#  liker_id     :integer          not null
#
# Indexes
#
#  index_likes_likable   (likable_type,likable_id)
#  index_likes_liker_id  (liker_id)
#  index_likes_unique    (likable_type,likable_id,liker_id) UNIQUE
#
# Foreign Keys
#
#  fk_likes_liker_id  (liker_id => users.id)
#

class Like < ActiveRecord::Base
  include Contributable

  belongs_to :liker, class_name: 'User', required: true
  belongs_to :likable, polymorphic: true, counter_cache: :likes_count, required: true
  validates_uniqueness_of :liker_id, scope: :likable

  class << self
    def updatable_columns
      [:_destroy, :id, :liker_id]
    end
  end
end
