class Card::NoteCard < Card
  include Taggable
  embedded_in :note

  class << self
    def updatable_columns
      super + [:tag]
    end
  end
end
