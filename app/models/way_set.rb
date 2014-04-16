class WaySet < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:recipe_id]

  acts_as_list scope: :recipe

  scope :sorted_by_position, ->{order :position}

  belongs_to :status
  has_many :ways, dependent: :destroy

  accepts_nested_attributes_for :ways, allow_destroy: true

  class << self
    def next_to status
      status.recipe.way_sets.find_by position: status.position
    end
  end
end
