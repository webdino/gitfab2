class Namespace < ActiveRecord::Base
  belongs_to :owner
  has_many :recipes

  delegate :name, to: :owner
end
