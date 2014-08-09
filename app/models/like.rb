class Like
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable

  belongs_to :liker, class_name: User.name
  embedded_in :likable, polymorphic: true

  class << self
    def updatable_columns
      [:_destroy, :id, :liker_id]
    end
  end
end
