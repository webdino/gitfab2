class Recipe < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:owner_id, :title, :description,
    materials_attributes: [:name, :url, :quantity, :size, :description],
    tools_attributes: [:name, :url, :description],
    statuses_attributes: [:description],
    ways_attributes: [:description]
  ]
  belongs_to :owner
  belongs_to :namespace
  has_many :contributors, through: :contributor_recipes
  has_many :contributor_recipes
  has_many :materials
  has_many :tools
  has_many :statuses
  has_many :ways
  accepts_nested_attributes_for :materials, :tools, :statuses, :ways
end
