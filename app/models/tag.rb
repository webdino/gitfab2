class Tag < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:name]
  has_many :recipe_tags
  has_many :recipes, through: :recipe_tags
  validates :name, presence: true, uniqueness: true
end
