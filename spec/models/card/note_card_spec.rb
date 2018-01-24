# frozen_string_literal: true

require 'spec_helper'

describe Card::NoteCard do
  it_behaves_like 'Card', :note_card
  it_behaves_like 'Taggable', :note_card

  let(:project) { FactoryGirl.create :user_project }
  let(:note_card) { FactoryGirl.create :note_card, note: project.note }

  describe '#is_taggable?' do
    subject { note_card.is_taggable? }
    it { is_expected.to be true }
  end

  describe '#after_create' do
    it do
      expect do
        note_card.run_callbacks :create
      end.to change(note_card.note, :num_cards).by 1
    end
  end

  describe '#after_delete' do
    it do
      expect do
        note_card.run_callbacks :destroy
      end.to change(note_card.note, :num_cards).by(-1)
    end
  end
end
