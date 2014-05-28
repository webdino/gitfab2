class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable
  include Likable

  belongs_to :user
  embedded_in :commentable, polymorphic: true

  scope :created_at_desc, ->{order "created_at DESC"}

  field :body

  class << self
    def updatable_columns
      [:body]
    end
  end
end
