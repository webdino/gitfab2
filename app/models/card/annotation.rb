class Card::Annotation < Card
  embedded_in :annotatable, polymorphic: true
  field :position
end
