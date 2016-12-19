class Card::State < Card
  include Annotatable
  belongs_to :recipe
  acts_as_list scope: :recipe

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to,
               annotations_attributes: Card::Annotation.updatable_columns
              ]
    end
  end
end

