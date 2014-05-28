class Collaboration
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :user
  belongs_to :project

  validates :project, presence: true
end
