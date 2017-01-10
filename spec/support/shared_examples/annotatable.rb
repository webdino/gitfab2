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
end
