class Card::NoteCard < Card
  embedded_in :note

  field :title

  class << self
    def updatable_columns
      super + [:title]
    end
  end
end
