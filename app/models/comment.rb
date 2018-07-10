# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text(65535)
#  commentable_type :string(255)      not null
#  likes_count      :integer          default(0), not null
#  oldid            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_comments_commentable  (commentable_type,commentable_id)
#  index_comments_created_at   (created_at)
#  index_comments_user_id      (user_id)
#
# Foreign Keys
#
#  fk_comments_user_id  (user_id => users.id)
#

class Comment < ActiveRecord::Base
  include Contributable
  include Likable

  belongs_to :user, required: true
  # TODO: required: true が付けられるかどうか要検討
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true

  scope :created_at_desc, -> { order 'created_at DESC' }

  class << self
    def updatable_columns
      [:_destroy, :body, :user_id]
    end
  end
end
