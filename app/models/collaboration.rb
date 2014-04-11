class Collaboration < ActiveRecord::Base
  belongs_to :user
  belongs_to :recipe

  validates :user, :recipe, presence: true
end
