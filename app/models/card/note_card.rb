class Card::NoteCard < Card
  include Taggable
  embedded_in :note

  after_create -> { note.inc num_cards: 1 }
  after_destroy -> { note.inc num_cards: -1 }

  class << self
    def updatable_columns
      super + [:tag]
    end
  end
end
