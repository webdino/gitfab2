class Card::Annotation < Card
  include Mongoid::Orderable
  embedded_in :annotatable, polymorphic: true
  orderable column: :position

  scope :ordered_by_position, ->{order("position ASC")}

  class << self
    def updatable_columns
      super + [:position, :move_to]
    end
  end
end
