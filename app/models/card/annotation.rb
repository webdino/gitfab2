class Card::Annotation < Card
  belongs_to :annotatable, polymorphic: true
  acts_as_list scope: :recipe

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to]
    end
  end
end
