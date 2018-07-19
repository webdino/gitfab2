# frozen_string_literal: true

shared_examples 'Annotatable' do |*factory_args|
  describe '#annotations' do
    let(:card) { FactoryBot.create(*factory_args) }
    let(:annotate) { FactoryBot.create(:annotation, card: card) }
    it do
      expect(card).to be_respond_to(:annotations)
    end

    it do
      expect(card.annotations).to be_member(annotate)
    end
  end

  describe 'annotationsを複製する' do
    subject(:dupped_card) do
      card.dup_document.tap(&:save!)
    end

    let(:card) do
      FactoryBot.create(*factory_args) do |card|
        FactoryBot.create_list(:annotation, annotation_count, card: card)
      end
    end
    let(:annotation_count) { 5 }

    it '数を維持すること' do
      expect(dupped_card.annotations.count).to eq(annotation_count)
    end
    it '順番・内容を維持すること' do
      card.annotations.to_a.shuffle
        .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }
      card.annotations.reload

      actual   = Card::Annotation.where(id: dupped_card.annotations.pluck(:id)).order(:position).map(&:title)
      expected = Card::Annotation.where(id: card       .annotations.pluck(:id)).order(:position).map(&:title)
      expect(actual).to eq(expected)
    end
    it '複製であること' do
      expect(dupped_card.annotations.map(&:id)).to_not eq(card.annotations.map(&:id))
    end
  end
end
