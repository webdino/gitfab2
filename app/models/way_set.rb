class WaySet < ActiveRecord::Base
  acts_as_list scope: :recipe

  scope :sorted_by_position, ->{order :position}

  belongs_to :recipe
  has_many :ways, dependent: :destroy

  class << self
    def next_to_status status
      status.recipe.way_sets.find_by position: status.position
    end
  end
end
