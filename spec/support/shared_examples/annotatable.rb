shared_examples 'Annotable' do |*factory_args|
  describe '#annotations' do
    let(:annotatable) { FactoryGirl.create(*factory_args) }
    let(:annotate) { FactoryGirl.create(:annotation, annotatable: annotatable) }
    it do
      expect(annotatable).to be_respond_to(:annotations)
    end

    it do
      expect(annotatable.annotations).to be_member(annotate)
    end
  end

  describe 'annotationsを複製する' do
    let(:annotatable) { FactoryGirl.create(*factory_args) }
    subject(:dupped_annotatable) do
      annotatable.dup_document.tap { |obj| obj.save! }
    end
    it '数を維持すること' do
      expect(dupped_annotatable.annotations.size).to eq(annotatable.annotations.size)
    end
    it '順番・内容を維持すること' do
      expect(Card::Annotation.where(id: dupped_annotatable.annotations.pluck(:id)).order(:position).map(&:title)).
        to eq(Card::Annotation.where(id: annotatable.annotations.pluck(:id)).order(:position).map(&:title))
    end
    it '複製であること' do
      expect(dupped_annotatable.annotations.map(&:id)).to_not eq(annotatable.annotations.map(&:id))
    end
  end

end
