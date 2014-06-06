class Card::RecipeCard < Card
  include Mongoid::Orderable
  embedded_in :recipe
  orderable column: :position

  validates :_type, :description, presence: true

  scope :ordered_by_position, ->{order("position ASC")}

  class << self
    def updatable_columns
      super + [:position]
    end
  end
end
