class Card::Annotation < Card
  embedded_in :annotatable, polymorphic: true
end
