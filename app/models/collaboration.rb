class Collaboration
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :owner, polymorphic: true
  belongs_to :project

  validates :project, presence: true
end
