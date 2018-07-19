# frozen_string_literal: true

describe Card::NoteCard do
  it_behaves_like 'Card', :note_card

  let(:note_card) { FactoryBot.create(:note_card) }
end
