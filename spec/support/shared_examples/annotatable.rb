# frozen_string_literal: true

shared_examples 'Annotable' do |*factory_args|
  describe '#annotations' do
    let(:annotatable) { FactoryBot.create(*factory_args) }
    let(:annotate) { FactoryBot.create(:annotation, annotatable: annotatable) }
    it do
      expect(annotatable).to be_respond_to(:annotations)
    end

    it do
      expect(annotatable.annotations).to be_member(annotate)
    end
  end

  describe 'annotationsを複製する' do
    subject(:dupped_annotatable) do
      annotatable.dup_document.tap(&:save!)
    end

    let(:annotatable) do
      FactoryBot.create(*factory_args) do |annotatable|
        FactoryBot.create_list(:annotation, annotation_count, annotatable: annotatable)
      end
    end
    let(:annotation_count) { 5 }

    it '数を維持すること' do
      expect(dupped_annotatable.annotations.count).to eq(annotation_count)
    end
    it '順番・内容を維持すること' do
      annotatable.annotations.to_a.shuffle
        .each_with_index { |s, i| s.tap { s.update(position: i + 1) } }
      annotatable.annotations.reload

      actual   = Card::Annotation.where(id: dupped_annotatable.annotations.pluck(:id)).order(:position).map(&:title)
      expected = Card::Annotation.where(id: annotatable       .annotations.pluck(:id)).order(:position).map(&:title)
      expect(actual).to eq(expected)
    end
    it '複製であること' do
      expect(dupped_annotatable.annotations.map(&:id)).to_not eq(annotatable.annotations.map(&:id))
    end
  end
end
