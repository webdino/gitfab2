# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text(65535)
#  created_at :datetime
#  updated_at :datetime
#  card_id    :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  fk_rails_c8dff2752a     (card_id)
#  index_comments_user_id  (user_id)
#
# Foreign Keys
#
#  fk_comments_user_id  (user_id => users.id)
#  fk_rails_...         (card_id => cards.id)
#

class Comment < ApplicationRecord
  belongs_to :card
  belongs_to :user

  validates :body, presence: true

  scope :created_at_desc, -> { order 'created_at DESC' }

  class << self
    def updatable_columns
      [:_destroy, :body, :user_id]
    end
  end
end
