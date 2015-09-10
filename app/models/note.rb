class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :note_cards, class_name: Card::NoteCard.name, cascade_callbacks: true
  embedded_in :project
  field :num_cards, type: Fixnum, default: 0

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.note_cards = note_cards.map(&:dup_document)
    end
  end
end
