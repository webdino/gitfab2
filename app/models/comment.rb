class Comment < ActiveRecord::Base
  include Contributable
  include Likable

  belongs_to :user, required: true
  # TODO: required: true が付けられるかどうか要検討
  belongs_to :commentable, polymorphic: true

  scope :created_at_desc, -> { order 'created_at DESC' }

  class << self
    def updatable_columns
      [:_destroy, :body, :user_id]
    end
  end
end
