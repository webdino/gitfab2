class Collaboration < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :recipe

  validates :user, :recipe, presence: true
end
