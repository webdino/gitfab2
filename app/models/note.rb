class Note < ActiveRecord::Base
  include MongoidStubbable

  has_many :note_cards, class_name: 'Card::NoteCard'
  belongs_to :project

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.note_cards = note_cards.map(&:dup_document)
    end
  end
end
