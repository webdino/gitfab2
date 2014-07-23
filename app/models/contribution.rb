class Contribution

  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable

  belongs_to :contributor, class_name: User.name
  embedded_in :contributable, polymorphic: true
end
