# frozen_string_literal: true

describe Card::NoteCard do
  it_behaves_like 'Card', :note_card
  it_behaves_like 'Taggable', :note_card

  let(:note_card) { FactoryBot.create(:note_card) }

  describe '#is_taggable?' do
    subject { note_card.is_taggable? }
    it { is_expected.to be true }
  end
end
