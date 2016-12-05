class Card::State < Card
  include MongoidStubbable
  belongs_to :recipe
  acts_as_list scope: :recipe

  scope :ordered_by_position, -> { order('position ASC') }
  accepts_nested_attributes_for :annotations

  class << self
    def updatable_columns
      super + [:position, :move_to,
               annotations_attributes: Card::Annotation.updatable_columns
              ]
    end
  end
end

