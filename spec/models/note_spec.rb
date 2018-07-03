# frozen_string_literal: true

describe Note do
  let(:note) { FactoryBot.create(:note) }

  it '#note_cards' do
    expect(note).to be_respond_to(:note_cards)
  end

  it '#project' do
    expect(note.project).to be_an_instance_of(Project)
  end

  it '#num_cards' do
    expect(note.num_cards).to eq(note.note_cards.size)
  end

  describe '#dup_document' do
    it '自身の複製を返すこと' do
      note_dupped = note.dup_document
      expect(note_dupped).to be_an_instance_of(Note)
      expect(note_dupped.id).to_not eq(note.id)
    end

    it 'note_cardsを複製すること' do
      note_dupped = note.dup_document
      expect(note_dupped.note_cards.size).to eq(note.note_cards.size)
      expect(note_dupped.note_cards[0].id).to_not eq(note.note_cards[0].id)
    end
  end
end
