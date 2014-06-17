require "spec_helper"

describe Card::NoteCard do
  let(:note_card){FactoryGirl.build :note_card}

  describe "#is_taggable?" do
    subject{note_card.is_taggable?}
    it{should be true}
  end
end
