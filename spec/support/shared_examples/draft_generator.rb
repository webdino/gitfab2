shared_examples 'DraftGenerator' do |obj|
  describe '#generate_draft' do
    it 'should be implemented' do
      aggregate_failures do
        expect(obj).to respond_to(:generate_draft)
        expect { obj.generate_draft }.not_to raise_error
      end
    end
  end
end
