class Card::RecipeCard < Card
  include Annotatable
  belongs_to :recipe
  acts_as_list

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to]
    end
  end
end
