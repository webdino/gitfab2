# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  num_cards  :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#
# Indexes
#
#  index_notes_num_cards   (num_cards)
#  index_notes_project_id  (project_id)
#
# Foreign Keys
#
#  fk_notes_project_id  (project_id => projects.id)
#

class Note < ActiveRecord::Base

  has_many :note_cards, class_name: 'Card::NoteCard', dependent: :destroy
  belongs_to :project, required: true

  def dup_document
    dup.tap do |doc|
      doc.note_cards = note_cards.map(&:dup_document)
    end
  end
end
