class Like
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable

  belongs_to :liker, class_name: User.name
  embedded_in :likable, polymorphic: true
end
