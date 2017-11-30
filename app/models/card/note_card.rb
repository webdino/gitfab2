class Card::NoteCard < Card
  include Taggable
  belongs_to :note, required: true

  after_create -> { note.increment!(:num_cards) }
  after_destroy -> { note.decrement!(:num_cards) }

  class << self
    def updatable_columns
      super + [:tag]
    end
  end
end
