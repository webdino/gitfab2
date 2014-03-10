class Recipe < ActiveRecord::Base
  belongs_to :owner
  belongs_to :namespace
  has_many :contributors, through: :contributor_recipes
  has_many :contributor_recipes
  has_many :materials
  has_many :tools
  has_many :statuses
  has_many :ways
end
