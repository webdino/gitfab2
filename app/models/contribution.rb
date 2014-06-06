class Contribution
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :user
  belongs_to :contributable, polymorphic: true

  validates :user, :contributable, presence: true
end
